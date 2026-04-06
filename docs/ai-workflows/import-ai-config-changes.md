# Import AI Config Changes

Use this workflow when Claude or Codex has created or changed home-directory AI skills, agents, or templates and you want to bring the safe subset back into this repo without clobbering the source-of-truth files.

## Phase 1: Review

Entry criteria:
1. The user wants to import AI config changes from `~/.claude`, `~/.codex`, `~/.copilot`, or `~/.agents`.

Actions:
1. Read `docs/ai-config-import-policy.md`.
2. Run `./scripts/review-ai-config-imports.sh`.
3. Read `.docs/ai/import-review.md`.
4. Classify the outcome:
   - only safe additions
   - review-required differences
   - blocked repo-managed or machine-local conflicts

Exit criteria:
1. You can explain which paths are safe, which need review, and which are blocked.

## Phase 2: Decision Gate

Entry criteria:
1. The review report exists.

Actions:
1. If the report includes blocked items, stop automatic import and summarize them.
2. If the report includes review-required items, stop automatic import and summarize them unless the user explicitly asks for deeper inspection of those paths.
3. Proceed automatically only when the report contains safe additions and no blocked or review-required items.
4. If the user explicitly wants only the safe subset, keep the flagged paths untouched and continue with a dry run to confirm the importer skips them.

Exit criteria:
1. Either the import is blocked with a clear summary, or the remaining import scope is limited to safe additions only.

## Phase 3: Safe Import

Entry criteria:
1. Only safe additions remain for import, either because the report was clean or because the user explicitly approved importing only the safe subset.

Actions:
1. Run `./scripts/sync-ai-configs.sh --dry-run`.
2. Confirm the dry-run output matches the safe-addition report.
3. Run `./scripts/sync-ai-configs.sh`.
4. Review `git status` and `git diff --stat`.

Exit criteria:
1. The repo contains only the expected additive imports.

## Phase 4: Closeout

Entry criteria:
1. The import completed successfully or was intentionally blocked.

Actions:
1. Update `.docs/ai/current-state.md`, `.docs/ai/next-steps.md`, and `.docs/ai/decisions.md` if the policy, tooling, or workflow changed.
2. If files were imported, make a small descriptive commit unless the user asked not to commit.
3. In the final response, state whether the import was blocked, dry-run only, or applied.

Exit criteria:
1. The repo state and the user-facing summary match the actual outcome.
