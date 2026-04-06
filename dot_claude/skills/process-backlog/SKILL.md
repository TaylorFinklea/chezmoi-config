---
name: process-backlog
description: Process Opus-tier backlog items that require design skill and cross-cutting changes. If fewer than 3 T3 items remain, enters planning mode to scan for architectural debt and populate new T3 items via structured product questions.
user-invocable: true
disable-model-invocation: true
---

# Process Backlog (Opus Tier)

Execute Opus-tier (T3) backlog items when Claude is the named roadmap owner. If T3 items are running low, switch to planning mode to populate more.

## Usage

`/process-backlog` — pick and execute the next T3 item
`/process-backlog plan` — force planning mode (skip to populating T3 items)
`/process-backlog audit` — run `/audit-backlog` to refresh T1/T2, then process T3

## Step 1: Read the Roadmap

1. Find the roadmap: `.docs/ai/roadmap.md` or `docs/ai/roadmap.md`
2. Read the `## Backlog` section
3. Read `<!-- tier3_owner: ... -->` and confirm it is `claude`
4. If the owner is `codex`, `copilot`, or `unassigned`, stop and report that Claude must not execute Opus work for this repo
5. Count unchecked T3 items: lines matching `- [ ]` under `### Opus`
6. Skip claimed items: `- [~]` means another agent is working on it

## Step 2: Branch Based on T3 State

### If 3+ unchecked T3 items exist (or no `plan` argument) → Execute Mode

1. Pick the first unchecked `- [ ]` item under `### Opus`
2. **Claim it**: change `- [ ]` to `- [~]` in the roadmap and commit:
   ```
   chore: claim backlog item — [short description]
   ```
3. Read all files referenced in the item. If the item doesn't specify files, use Grep/Glob to locate the relevant code.
4. Implement the change. Follow the repo's CLAUDE.md for code style and patterns.
5. Run the build/test command from the repo's CLAUDE.md.
6. **If build passes**:
   - Mark `- [~]` → `- [x]` in the roadmap
   - Commit the code change + roadmap update together:
     ```
     feat|fix|refactor: [description of the change]
     ```
7. **If build fails**:
   - Revert the code changes (`git checkout -- .` for the code files only)
   - Mark `- [~]` → `- [ ]` in the roadmap
   - Add a failure comment: `<!-- build-failed: YYYY-MM-DD [1-line error summary] -->`
   - Commit the roadmap with: `docs: mark backlog item as failed — [description]`
   - Move to the next item
8. **Re-read the roadmap** after each commit (another agent may have claimed items)
9. Pick the next unchecked T3 item. Repeat until done or the user interrupts.

### If fewer than 3 unchecked T3 items remain (or `plan` argument) → Planning Mode

Do NOT start coding. Enter a planning session to populate T3 items.

#### Planning Step 1: Gather Context

1. Read the full roadmap, `current-state.md`, `next-steps.md`, and `decisions.md`
2. Summarize what milestones are complete and what's left
3. Scan the codebase for T3-worthy patterns using an Explore agent (thoroughness: "very thorough"):

**T3 candidate patterns to scan for:**
- Modules/services with no corresponding test file
- Public API surfaces that have grown past 15+ endpoints without versioning or grouping
- Cross-cutting concerns handled inconsistently (error handling in 3 different styles, logging in some files but not others)
- Services over 500 lines that mix multiple responsibilities
- Missing integration tests for critical user flows
- Data models with no migration strategy documented
- Security boundaries (auth, validation) that are per-endpoint instead of centralized

#### Planning Step 2: Present Candidates

Use `AskUserQuestion` with **multiSelect** options. Present 5-8 concrete T3 candidates discovered from the scan. Each option should be specific:

```
Which of these T3 items should be added to the backlog?

- "Add unit tests for AuthManager (sign-in flows, session management, token refresh)"
- "Refactor EventService — split 400-line file into query, mutation, and subscription modules"
- "Design and implement centralized error handling middleware (currently 3 different patterns)"
- "Add integration tests for the complete meal planning workflow (create → draft → approve → export)"
- "Audit and consolidate API validation — 12 endpoints do inline validation, should use shared schemas"
```

#### Planning Step 3: Prioritize

Use `AskUserQuestion` with **select** to determine priority order for the selected items.

#### Planning Step 4: Refresh T1/T2 (Optional)

Use `AskUserQuestion` with **select**:
```
Should I also run /audit-backlog to refresh Haiku and Sonnet tier items?
- "Yes — scan for new T1/T2 items too"
- "No — just add the T3 items"
```

If yes, invoke the `audit-backlog` skill.

#### Planning Step 5: Write and Execute

1. Add the new T3 items to `### Opus` in the roadmap with descriptive text
2. Preserve the existing `tier3_owner` value unless the user explicitly asked to change the architect
3. Commit: `docs: process-backlog planning — added N Opus-tier items`
4. Begin executing the first new T3 item (switch to Execute Mode)

## After All Items Are Done

Update handoff docs:
1. `current-state.md` — what T3 items were completed, build status
2. `next-steps.md` — check off completed items, note remaining T3 work

Output a summary:

```
## Backlog Processing Results

| Item | Status | Commit |
|------|--------|--------|
| Add unit tests for AuthManager | Done | abc1234 |
| Refactor EventService | Build failed — missing import | skipped |

T3 remaining: N items
```
