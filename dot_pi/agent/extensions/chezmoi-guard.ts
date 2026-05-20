/**
 * Chezmoi Guard Extension
 *
 * Dotfile-work safety for the chezmoi source repo:
 * 1. On session start inside a chezmoi source tree, shows a reminder widget.
 * 2. Confirms before any `chezmoi apply` run via bash; blocks it outright in
 *    non-interactive sessions where no one can confirm.
 *
 * Repo detection is filesystem-only (a .chezmoi* marker), so the extension
 * spawns no subprocesses. Live drift counts are available on demand via the
 * /drift prompt template. The drift policy itself is carried by AGENTS.md in
 * the source repo, which pi loads as a context file.
 */

import * as fs from "node:fs";
import * as path from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

function inChezmoiSource(startDir: string): boolean {
	let dir = startDir;
	for (let depth = 0; depth < 6; depth++) {
		try {
			if (fs.readdirSync(dir).some((entry) => entry.startsWith(".chezmoi"))) return true;
		} catch {
			return false;
		}
		const parent = path.dirname(dir);
		if (parent === dir) break;
		dir = parent;
	}
	return false;
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", async (_event, ctx) => {
		if (!ctx.hasUI) return;
		if (!inChezmoiSource(ctx.sessionManager.getCwd())) return;

		ctx.ui.setWidget("chezmoi-guard", [
			"chezmoi source repo",
			"  decide drift direction (source vs home) before editing; never commit secrets",
			"  run /drift to triage pending changes",
		]);
	});

	pi.on("tool_call", async (event, ctx) => {
		if (event.toolName !== "bash") return;
		const command = String(event.input.command ?? "");
		if (!/\bchezmoi\s+apply\b/.test(command)) return;

		if (!ctx.hasUI) {
			return { block: true, reason: "chezmoi apply blocked: no interactive session to confirm." };
		}
		const ok = await ctx.ui.confirm("chezmoi apply", `Run this chezmoi apply?\n\n${command}`);
		if (!ok) return { block: true, reason: "chezmoi apply declined by user" };
	});
}
