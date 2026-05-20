/**
 * Observability Extension
 *
 * Appends a structured JSONL trace of every pi session: provider requests,
 * response status + rate-limit headers, tool calls, per-message token usage
 * and cost, and per-agent-loop aggregates.
 *
 * One file per session: <logDir>/session-<sessionId>.jsonl
 * logDir defaults to ~/.pi/agent/logs, overridable with PI_OBSERVABILITY_DIR.
 *
 * This is the local-visibility counterpart to routing pi through the LiteLLM
 * proxy: when pi talks directly to a provider (e.g. ChatGPT/Codex subscription
 * auth), this trace is where cost and token accounting still lands.
 */

import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import { randomUUID } from "node:crypto";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const LOG_DIR = process.env.PI_OBSERVABILITY_DIR || path.join(os.homedir(), ".pi", "agent", "logs");

// Response headers worth keeping; the rest are noise.
const KEEP_HEADER = /ratelimit|rate-limit|retry-after|x-request-id|request-id|x-should-retry/i;

function summarizeInput(toolName: string, input: Record<string, unknown>): unknown {
	switch (toolName) {
		case "bash":
			return { command: input.command };
		case "read":
		case "ls":
		case "find":
			return { path: input.path, pattern: input.pattern };
		case "grep":
			return { path: input.path, pattern: input.pattern };
		case "write":
		case "edit":
			return { path: input.path };
		default: {
			const json = JSON.stringify(input);
			return json.length > 300 ? `${json.slice(0, 300)}...` : input;
		}
	}
}

export default function (pi: ExtensionAPI) {
	const runId = randomUUID();
	let requestSeq = 0;
	let warned = false;

	function write(sessionId: string | undefined, event: string, fields: Record<string, unknown>): void {
		try {
			fs.mkdirSync(LOG_DIR, { recursive: true });
			const file = path.join(LOG_DIR, `session-${sessionId || runId}.jsonl`);
			const record = { ts: new Date().toISOString(), runId, sessionId, event, ...fields };
			fs.appendFileSync(file, `${JSON.stringify(record)}\n`);
		} catch (err) {
			// Telemetry must never break the agent, but should not vanish either.
			if (!warned) {
				warned = true;
				console.error(`[observability] log write failed: ${(err as Error).message}`);
			}
		}
	}

	pi.on("session_start", async (event, ctx) => {
		write(ctx.sessionManager.getSessionId(), "session_start", {
			reason: event.reason,
			cwd: ctx.sessionManager.getCwd(),
			sessionFile: ctx.sessionManager.getSessionFile(),
			model: ctx.model?.id,
		});
	});

	pi.on("before_provider_request", async (_event, ctx) => {
		write(ctx.sessionManager.getSessionId(), "provider_request", { requestSeq: ++requestSeq });
	});

	pi.on("after_provider_response", async (event, ctx) => {
		const headers: Record<string, string> = {};
		for (const [k, v] of Object.entries(event.headers)) {
			if (KEEP_HEADER.test(k)) headers[k] = v;
		}
		write(ctx.sessionManager.getSessionId(), "provider_response", {
			requestSeq,
			status: event.status,
			headers,
		});
	});

	pi.on("tool_call", async (event, ctx) => {
		write(ctx.sessionManager.getSessionId(), "tool_call", {
			toolName: event.toolName,
			toolCallId: event.toolCallId,
			input: summarizeInput(event.toolName, event.input),
		});
	});

	pi.on("tool_result", async (event, ctx) => {
		write(ctx.sessionManager.getSessionId(), "tool_result", {
			toolName: event.toolName,
			toolCallId: event.toolCallId,
			isError: event.isError,
		});
	});

	pi.on("message_end", async (event, ctx) => {
		const msg = event.message;
		if (msg.role !== "assistant") return;
		write(ctx.sessionManager.getSessionId(), "assistant_message", {
			provider: msg.provider,
			model: msg.responseModel || msg.model,
			api: msg.api,
			stopReason: msg.stopReason,
			usage: msg.usage,
		});
	});

	pi.on("agent_end", async (event, ctx) => {
		const assistantMessages = event.messages.filter((m) => m.role === "assistant");
		const total = { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, totalTokens: 0, cost: 0 };
		for (const m of assistantMessages) {
			const u = m.usage;
			total.input += u.input;
			total.output += u.output;
			total.cacheRead += u.cacheRead;
			total.cacheWrite += u.cacheWrite;
			total.totalTokens += u.totalTokens;
			total.cost += u.cost.total;
		}
		write(ctx.sessionManager.getSessionId(), "agent_end", {
			turns: assistantMessages.length,
			usage: total,
		});
	});
}
