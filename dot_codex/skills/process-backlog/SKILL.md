---
name: process-backlog
description: Process Haiku and Sonnet tier backlog items from the roadmap. Picks unchecked items, implements fixes one at a time, verifies the build, and commits each independently.
---

# Process Backlog (Haiku + Sonnet Tiers)

Execute Haiku-tier (T1) and Sonnet-tier (T2) backlog items from the roadmap. These are mechanical fixes and moderate refactors that don't require design decisions.

**You must NEVER work on Opus-tier items.** Those are reserved for the tier3_owner (typically Claude).

## Usage

`/process-backlog` — process T1 items first, then T2
`/process-backlog haiku` — only Haiku-tier items
`/process-backlog sonnet` — only Sonnet-tier items
`/process-backlog N` — process at most N items, then stop

## Step 1: Find and Read the Roadmap

Check for the roadmap in this order:
- `.docs/ai/roadmap.md`
- `docs/ai/roadmap.md`

Read the `## Backlog` section. Confirm that a `<!-- tier3_owner: ... -->` comment exists — this means Opus items are off-limits.

## Step 2: Select Items

1. Parse unchecked items (`- [ ]`) from the `### Haiku` and `### Sonnet` sections
2. **Skip claimed items**: `- [~]` means another agent is already working on it
3. **Skip flagged items**: anything with `<!-- needs-discussion -->` or `<!-- design-TBD -->`
4. **Default order**: all Haiku items first, then Sonnet
5. If argument is `haiku` or `sonnet`, filter to that tier only
6. If argument is a number N, cap at N items total

## Step 3: Process Each Item

For each selected item, one at a time:

### 3a. Claim

Change `- [ ]` to `- [~]` in the roadmap and commit:
```
chore: claim backlog item — [short description]
```

### 3b. Read Before Editing

Read the file(s) referenced in the item. Verify they exist and check the current state of the code around the referenced lines. If line numbers have shifted, locate the correct code by searching for the described pattern.

### 3c. Implement

Make the fix described in the item. Follow these rules strictly:

- **Do not change anything beyond what the item describes.**
- Do not add comments, docstrings, or type annotations to code you didn't change.
- Do not refactor surrounding code.
- Do not rename variables or reformat lines you didn't need to touch.
- If the item says "fix empty catch block", fix that catch block only.

### 3d. Verify the Build

Find the build/test command from the repo's CLAUDE.md (look for a "Verification" or "Build Commands" section). Common patterns:
- Rust: `cargo build --workspace && cargo test --workspace && cargo clippy --workspace -- -D warnings`
- Swift: `xcodebuild build -project ... -scheme ... CODE_SIGNING_ALLOWED=NO`
- Python: `pytest` or `make test`
- TypeScript: `npm run build && npm test`
- Docker: `docker compose config -q`

Run the build command.

### 3e. Complete or Fail

**If build passes:**
- Change `- [~]` to `- [x]` in the roadmap
- Commit the code change AND the roadmap update together:
  ```
  fix|refactor: [description matching the backlog item]
  ```

**If build fails:**
- Revert code changes (restore the files you edited to their pre-change state)
- Change `- [~]` back to `- [ ]` in the roadmap
- Add a comment after the item: `<!-- build-failed: YYYY-MM-DD [1-line error] -->`
- Commit just the roadmap: `docs: mark backlog item as failed — [description]`
- Move to the next item

### 3f. Re-Read and Continue

After each commit, re-read the roadmap's Backlog section. Another agent may have claimed items while you were working. Pick the next unchecked item and repeat.

## Step 4: Report

When finished (all items done, hit the cap, or no more items), output:

```
## Backlog Processing Results

| Item | Tier | Status |
|------|------|--------|
| Fix empty catch in auth.py:42 | Haiku | Done |
| Add a11y labels to IconButton | Haiku | Done |
| Split EventService (400 lines) | Sonnet | Build failed |

Haiku remaining: N items
Sonnet remaining: N items
```

## Rules

- Read files before editing them.
- One commit per item (claim commit + completion commit).
- **Do not push.** The user will review and push.
- Stop and report if you get stuck — do not guess.
- **Never touch Opus-tier items**, regardless of what they say.
- If all items are done, report "Backlog empty for Haiku/Sonnet tiers" and stop.
