/**
 * Confirm Bash Extension
 *
 * Prompts before destructive shell commands, and blocks them outright in
 * non-interactive sessions where no one can confirm. A heuristic guard, not
 * a sandbox: pattern matching catches common forms, not every phrasing.
 *
 * `chezmoi apply` is intentionally not listed here; chezmoi-guard owns it.
 * File-write protection for .env and similar lives in protected-paths.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const RULES: { test: RegExp; label: string }[] = [
	{ test: /\brm\s+-[a-z]*r[a-z]*f[a-z]*\b/i, label: "rm -rf" },
	{ test: /\brm\s+-[a-z]*f[a-z]*r[a-z]*\b/i, label: "rm -fr" },
	{ test: /\brm\s+(-[a-z]+\s+)*--(recursive|force)\b/i, label: "rm --recursive/--force" },
	{ test: /\bsudo\b/i, label: "sudo" },
	{ test: /\bgit\s+reset\s+--hard\b/i, label: "git reset --hard" },
	{ test: /\bgit\s+clean\s+-[a-z]*f/i, label: "git clean -f" },
	{ test: /\bgit\s+push\b[^|;&]*(--force\b|\s-f\b)/i, label: "git push --force" },
	{ test: /\bdd\s+if=/i, label: "dd if=" },
	{ test: /\bmkfs\b/i, label: "mkfs" },
];

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event, ctx) => {
		if (event.toolName !== "bash") return;
		const command = String(event.input.command ?? "");
		const hit = RULES.find((rule) => rule.test.test(command));
		if (!hit) return;

		if (!ctx.hasUI) {
			return {
				block: true,
				reason: `Destructive command (${hit.label}) blocked: no interactive session to confirm.`,
			};
		}
		const ok = await ctx.ui.confirm("Destructive command", `Allow this ${hit.label}?\n\n${command}`);
		if (!ok) return { block: true, reason: `${hit.label} declined by user` };
	});
}
