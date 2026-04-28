---
name: migrate-slim-overlay
description: Per-repo migration to the slim agent overlay. Detects legacy multi-tier protocol artifacts (tier3_owner markers, [~] claim markers, three-tier backlog table, next-steps.md, ai-workflows docs, dual CLAUDE.md/AGENTS.md, stale workflow-skill references) in the current repo and converts them to the slim shape (AGENTS.md canonical, prose tier hints, no claim ceremony). Idempotent. One-shot — use /purge-migrate-skills to remove this and the sibling skill once your sweep is done.
user-invocable: true
disable-model-invocation: true
---

# Migrate to Slim Agent Overlay

One-shot per-repo migration. Converts the legacy multi-tier protocol layer (tier3_owner, `[~]` claim ceremony, formal phase execution, audit-backlog / process-backlog / resume-and-continue / phase-execution / import-ai-config-changes skill mentions) to the slim overlay where `AGENTS.md` is canonical and backlog items are self-contained with prose tier hints.

**Per-project, not per-machine.** Run inside each repo separately. Does not touch global `~/AGENTS.md`, `~/.claude/`, etc.

**Idempotent** — safe to re-run; skips state that's already migrated.

## Step 1: Detect state

Inventory the current repo. Run all of these before showing anything to the user, and record results:

| Check | Command |
|---|---|
| `.docs/ai/` exists | `test -d .docs/ai && ls .docs/ai` |
| `tier3_owner` markers | `grep -c 'tier3_owner' .docs/ai/roadmap.md 2>/dev/null` |
| `[~]` claim markers | `grep -c '\[~\]' .docs/ai/roadmap.md 2>/dev/null` |
| Three-tier backlog headers | `grep -E '^### (Haiku\|Sonnet\|Opus)' .docs/ai/roadmap.md 2>/dev/null` |
| `next-steps.md` with content | `test -s .docs/ai/next-steps.md` |
| `inbox/` exists | `test -d .docs/ai/inbox` |
| `docs/ai-workflows/` | `test -d docs/ai-workflows` |
| `docs/ai-roadmap-system.md` | `test -f docs/ai-roadmap-system.md` |
| `docs/ai-config-import-policy.md` | `test -f docs/ai-config-import-policy.md` |
| `CLAUDE.md` exists | `test -f CLAUDE.md` |
| `AGENTS.md` exists | `test -f AGENTS.md` |
| Stale skill/protocol refs | `grep -lE 'process-backlog\|audit-backlog\|phase-execution\|resume-and-continue\|import-ai-config\|tier3_owner' AGENTS.md CLAUDE.md README.md copilot-instructions.md 2>/dev/null` |
| Legacy workflow skills in repo-level dir | `find .claude/skills .codex/skills .copilot/skills -maxdepth 1 -type d \( -name 'audit-backlog' -o -name 'process-backlog*' -o -name 'phase-execution' -o -name 'resume-and-continue' -o -name 'import-ai-config-changes' \) 2>/dev/null` |

Also check git state:
- Working tree clean? `git status --short` — if non-empty, warn and ask user to stash or commit first
- Branch name? If on `main`/`master`, ask whether to create `chore/slim-overlay-migration` first

## Step 2: Plan

Print a numbered checklist showing what needs to change vs what's already migrated. Example:

```
Detected in this repo:
✓ .docs/ai/ exists
✓ 1 tier3_owner marker in roadmap.md
✓ 3 [~] claim markers in roadmap.md
✓ Haiku/Sonnet/Opus three-tier backlog table
✓ next-steps.md (24 lines)
✓ docs/ai-workflows/ (6 files)
✓ docs/ai-roadmap-system.md
✓ CLAUDE.md (180 lines), AGENTS.md (does not exist)
✓ Stale references in README.md (4 mentions)

Migration plan:
1. Strip tier3_owner block from .docs/ai/roadmap.md
2. Convert 3 [~] markers → [ ] in .docs/ai/roadmap.md
3. Replace three-tier table with prose-tier-hint Backlog
4. Fold next-steps.md → roadmap.md "Now / Next / Later"; delete next-steps.md
5. Delete docs/ai-workflows/ and docs/ai-roadmap-system.md
6. Move shared content CLAUDE.md → AGENTS.md (canonical); reduce CLAUDE.md to thin pointer + Claude-specific overrides
7. Strip 4 stale references from README.md

Already migrated (skipped):
- .docs/ai/inbox/ (does not exist)
- .docs/ai/decisions.md (preserved as historical record)
- docs/ai-config-import-policy.md (does not exist)
- No legacy workflow skills in repo-level .claude/skills/, .codex/skills/, .copilot/skills/
```

## Step 3: Confirm

Use `AskUserQuestion` (or the equivalent for the active harness) with three options:

1. **Apply all** — execute every planned step without further prompts
2. **Walk through each step** — for each step, show the specific change and confirm
3. **Cancel** — exit without changes

On "walk through": for every step, show the before/after diff (use Edit tool's preview or print to chat) and ask `Apply / Skip / Cancel`.

## Step 4: Execute

For each approved step:

### 4.1 — Strip tier3_owner block

Edit `.docs/ai/roadmap.md`. Remove:
- The line `<!-- tier3_owner: ... -->`
- Adjacent comment lines explaining valid values, populate-during-audits guidance, etc.

Leave the surrounding markdown structure intact.

### 4.2 — Convert claim markers

In `.docs/ai/roadmap.md`, replace `[~]` with `[ ]` (use Edit's `replace_all: true`).

### 4.3 — Replace three-tier table

Read the current Backlog section. Three sub-cases:

- **Empty placeholders only** (`<!-- empty -->` etc.): replace the whole `## Backlog` section with the slim template:
  ```markdown
  ## Backlog

  > Self-contained items any agent can execute. Each entry should include scope, file paths, acceptance criteria, verification steps, and a prose tier hint ("Haiku candidate", "Sonnet — multi-file", "needs Opus to scope").

  <!-- Format example:
  ### Add foo to bar
  **Scope**: …
  **Files**: `path/to/file.ts:42`
  **Acceptance**: …
  **Verify**: `npm test -- foo`
  **Tier hint**: Sonnet — touches 2 files, no design decisions
  -->
  ```
- **Concrete items present**: migrate each item under its old tier into a flat list under `## Backlog`, append the tier name as a prose hint (`**Tier hint**: Haiku — mechanical rename`). Drop the `### Haiku`, `### Sonnet`, `### Opus` subheaders.
- **Mixed**: handle item-by-item; ask the user when an item's tier is ambiguous.

### 4.4 — Fold next-steps.md

Read `.docs/ai/next-steps.md`. Insert a `## Now / Next / Later` section into `.docs/ai/roadmap.md` placed between `## Vision` and `## Milestones` (or at top if no Vision section). Categorize items by urgency cues:

- **Now**: actions with imperative verbs about immediate verification / setup steps that block other work
- **Next**: items mentioning "after X is done" or queued for the next session
- **Later**: items with "decide whether", "consider", "if you want"

If urgency is unclear, dump everything under **Now** and let the user re-sort.

Then `git rm .docs/ai/next-steps.md`.

### 4.5 — Delete inbox

`git rm -rf .docs/ai/inbox` if it exists.

### 4.6 — Delete meta-docs

For each that exists: `git rm -rf docs/ai-workflows docs/ai-roadmap-system.md docs/ai-config-import-policy.md`. Skip ones that don't exist.

If `docs/` is now empty, leave it (don't delete the directory itself).

### 4.7 — CLAUDE.md / AGENTS.md flip

Three sub-cases:

**4.7a — Only CLAUDE.md exists**

Read full content. Classify each section as **shared** or **Claude-specific**:

| Shared (→ AGENTS.md) | Claude-specific (→ thin CLAUDE.md) |
|---|---|
| Handoff State (Session Start/End) | TaskCreate / TaskUpdate / AskUserQuestion / ExitPlanMode tool mappings |
| Backlog Conventions | Plan-mode behavior expectations |
| Substantial-Work Convention | Skill names (`/init-ai-docs`, `/handoff-prompt`, `/plan-backlog-item`, etc.) |
| Common Working Style (shell, commits) | Hook references (auto-commit-on-stop) |
| Rules | Memory directory references |
| API Keys | |

Write a new `AGENTS.md` from the shared content. Reduce `CLAUDE.md` to:

```markdown
# Claude Code Overrides

For shared agent rules, see [`AGENTS.md`](./AGENTS.md). The notes below only cover Claude-Code-specific behavior.

## [whatever-Claude-specific-bits-survived]
```

If after classification there's nothing Claude-specific, delete `CLAUDE.md` entirely and tell the user.

**4.7b — Only AGENTS.md exists**

Nothing structural to do; defer to step 4.8 for stale-reference cleanup inside AGENTS.md.

**4.7c — Both exist**

Read both. Print a side-by-side comparison to the user (use the `diff` command or summarize sections). Ask:

> Where should each of these sections live? Move to AGENTS.md, keep in CLAUDE.md, or delete?

Apply the user's selection. After consolidation, AGENTS.md should hold the shared content; CLAUDE.md should be thin with only Claude-specific overrides (or deleted if none).

### 4.8 — Stale-reference cleanup

For each instruction file (`AGENTS.md`, `CLAUDE.md`, `copilot-instructions.md`, `README.md`):

```bash
grep -nE 'process-backlog|audit-backlog|phase-execution|resume-and-continue|import-ai-config|tier3_owner' <file>
```

For each match, show the surrounding line(s) and ask:

- **Strip** — remove the reference (and its surrounding sentence/bullet if the rest doesn't read well)
- **Keep as historical** — leave alone (matches in commit messages quoted in docs, decision-log entries, etc.)
- **Skip** — leave alone, no opinion

Don't blindly delete. References may be intentional history (decisions.md entries documenting a now-reversed protocol).

### 4.9 — Repo-level workflow skills (uncommon)

If the repo has its own `.claude/skills/`, `.codex/skills/`, or `.copilot/skills/` containing legacy workflow skill dirs (audit-backlog, process-backlog, etc.), `git rm -rf` them. This is rare — most repos use the user-level skill trees.

## Step 5: Verify and commit

After all approved steps complete:

1. Run `git diff --stat` and `git status`
2. Print a one-paragraph summary: how many files changed, key shapes (e.g., "AGENTS.md grew from 0 → 142 lines; CLAUDE.md shrank from 180 → 22 lines")
3. Suggest a commit message:
   ```
   chore: migrate to slim agent overlay

   Strip tier3_owner / [~] claim protocol; flip canonical to AGENTS.md;
   remove ai-workflows protocol docs and stale workflow-skill references.
   ```
4. Ask: "Commit now? [Y/n]". On yes, create the commit. On no, leave staged for the user to review.

**Do not push.**

## Failure modes

- **No `.docs/ai/`**: skip steps 4.1–4.6; jump to 4.7 (instruction-file flip only).
- **No instruction files at all**: report "Nothing to migrate" and exit.
- **Conflicting CLAUDE.md / AGENTS.md content (case 4.7c)**: stop, show the diff, force the user to resolve before continuing.
- **Working tree dirty before starting**: warn and require user to stash/commit first. Do not auto-stash.
- **Detached HEAD or rebase in progress**: refuse to run; print `git status` and exit.
- **User picks "Walk through" then cancels mid-step**: leave already-applied steps in place (staged but uncommitted), report which steps were applied vs skipped.

## After your migration sweep is done

Use `/purge-migrate-skills` (sibling skill) from any installed harness to remove this skill and any other `migrate-*` skills from your `~/git/chezmoi-config` repo and propagate the deletions to home directories via `chezmoi apply`.
