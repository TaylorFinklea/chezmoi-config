---
name: process-backlog-opus
description: Process Opus-tier backlog items when Codex is the named tier3_owner. Reads the roadmap owner, claims one Opus item at a time, verifies the build, and commits each independently.
---

# Process Backlog (Opus Tier for Codex)

Execute Opus-tier (T3) backlog items only when the roadmap explicitly says `tier3_owner: codex`.

## Usage

`/process-backlog-opus` — pick and execute the next T3 item
`/process-backlog-opus plan` — stop after assessing whether Codex is allowed to work T3

## Step 1: Read the Roadmap

1. Find the roadmap: `.docs/ai/roadmap.md` or `docs/ai/roadmap.md`
2. Read the `## Backlog` section
3. Read `<!-- tier3_owner: ... -->`
4. If the owner is not `codex`, stop and report the named owner
5. Count unchecked T3 items: lines matching `- [ ]` under `### Opus`
6. Skip claimed items: `- [~]` means another agent is working on it

## Step 2: Execute

1. Pick the first unchecked `- [ ]` item under `### Opus`
2. Claim it by changing `- [ ]` to `- [~]` in the roadmap and committing:
   ```
   chore: claim backlog item — [short description]
   ```
3. Read every referenced file before editing
4. Implement only what the backlog item describes
5. Run the repo build/test command from `CLAUDE.md` or repo instructions
6. If the build passes:
   - Mark `- [~]` to `- [x]`
   - Commit the code change and roadmap update together
7. If the build fails:
   - Revert the code changes for the edited files
   - Mark `- [~]` back to `- [ ]`
   - Add `<!-- build-failed: YYYY-MM-DD [1-line error summary] -->`
   - Commit just the roadmap failure note

## Rules

- Never start T3 work unless `tier3_owner: codex`
- Read files before editing them
- Do not change anything beyond what the backlog item describes
- Do not push; the user reviews and pushes
- Re-read the roadmap after each item because another agent may claim work while you are running
