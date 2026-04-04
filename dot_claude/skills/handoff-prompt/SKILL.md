---
name: handoff-prompt
description: Generate a self-contained prompt for a less sophisticated AI agent to continue backlog work when Claude is rate-limited. Reads current roadmap/backlog state, picks appropriate items, and produces a copy-pasteable prompt.
user-invocable: true
disable-model-invocation: true
---

# Handoff Prompt Generator

Generate a prompt to hand off backlog work to a cheaper/less sophisticated AI agent (Gemini, GLM, GPT, Sonnet, etc.) when Claude is rate-limited.

## Usage

`/handoff-prompt` — pick remaining backlog items automatically
`/handoff-prompt trivial` — only trivial-tier items
`/handoff-prompt minor` — only minor-tier items
`/handoff-prompt 3` — limit to N items

## What to Do

1. **Read the roadmap** at `.docs/ai/roadmap.md` (or the path specified in the repo's CLAUDE.md). If the repo's roadmap references a unified roadmap in another repo, read that instead.

2. **Identify remaining backlog items** — items that are NOT struck through (~text~) or marked [x].

3. **Check recent git history** — run `git log --oneline -10` to see what was recently committed. If any commits look like they completed backlog items that aren't marked done in the roadmap, note them.

4. **Select items** based on the argument:
   - Default: pick up to 4 items, trivial first, then minor
   - `trivial`: only `[trivial]` items
   - `minor`: only `[minor]` items
   - A number: limit to that many items

5. **For each item**, read the referenced files to gather:
   - Exact file paths (verify they exist)
   - Current content around the lines that need to change
   - Any patterns the agent should follow (look at recent commits for style)

6. **Generate the prompt** using this structure:

```
You are working on [project name] — [one-line description].

## Repos
- [repo name]: [absolute path]
[repeat for each repo involved]

## Rules
- Read files before editing them.
- Make one commit per item. Do not push.
- Do not change anything beyond what the item describes.
- Do not add comments, docstrings, or type annotations to code you didn't change.
- Run one shell command at a time. Never chain with &&.

## Verify changes with:
[build/test command from CLAUDE.md]

## Work through these items in order. Stop if you get stuck.

### 1. [tier/repo] Item title
Repo: [which repo]
[Detailed instructions with exact file paths, what to find, what to change]
[Include code templates where helpful — reduces ambiguity]
[Include the exact commit message to use]

### 2. ...

---

After completing items, report what you did and what (if anything) you couldn't finish.
```

7. **Output the prompt** as a fenced code block so the user can copy-paste it directly into another agent.

## Key Principles

- **Self-contained**: The prompt must include ALL context the agent needs. It cannot read CLAUDE.md, roadmap, or other docs — everything must be inline.
- **Explicit file paths**: Always use absolute paths or paths relative to the repo root.
- **Code templates**: For trivial items, include the exact code to write. For minor items, include the pattern to follow.
- **One commit per item**: Each item should be independently committable.
- **Verify command**: Always include the build/test command.
- **Read-first**: Always tell the agent to read files before editing.
- **Stop on stuck**: Tell the agent to stop and report rather than guess.

## After Handoff: Resume Protocol

When Claude resumes after a handoff (next session or after rate limit clears), it MUST:

1. Run `git log --oneline -10` in each repo to see what the other agent committed
2. Read the changed files to understand what was done
3. Verify the build still passes
4. Update the roadmap to mark completed items
5. Note any issues or incomplete work before starting new phase work

This is critical — the other agent may have made mistakes or partial changes that need cleanup before proceeding.
