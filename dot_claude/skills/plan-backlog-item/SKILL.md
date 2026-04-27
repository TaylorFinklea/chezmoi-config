---
name: plan-backlog-item
description: Author a self-contained backlog item — scope, files, acceptance, verify, tier hint — and append it to .docs/ai/roadmap.md. The entry must let any cheaper agent (Sonnet, Haiku, GPT, Kimi) execute the work without your back-context. Best run in Opus.
user-invocable: true
disable-model-invocation: true
---

# Plan Backlog Item

Produce a richly-contexted backlog entry and append it to `.docs/ai/roadmap.md`. The entry must be self-contained — any agent picking it up later must be able to execute without reading your conversation, CLAUDE.md, or any other handoff doc beyond the roadmap itself.

## When to use this

When you (in Opus or another high-capability model) want to defer work to a cheaper model later. Examples:

- You scoped a refactor but it's mechanical from here — write it up, hand it to Sonnet
- You designed an API change but the Haiku tier can do the call-site updates
- You're rate-limited and want a queue of items the user can hand to GPT or Kimi later

Don't use this for ad-hoc reminders or single-line fixes — those go in `current-state.md` or commit messages, not the backlog.

## Inputs

The user describes a feature, fix, or refactor. They may also specify:

- A target tier ("write this so Haiku can execute it")
- File paths to focus on
- Constraints (must keep API stable, must work on iOS 16+, etc.)

If the description is too vague to verify or scope, use `AskUserQuestion` to clarify before drafting. Don't pad the entry with assumptions.

## What to produce

Append an entry to `.docs/ai/roadmap.md` under `## Backlog` with this shape:

```markdown
### [Imperative title — what gets done]

**Scope**: [1–2 sentences. The smallest unit of work that delivers value. No "tidy up while you're there" expansions.]

**Files**:
- `path/to/file.ext:42-87` — [what's there now and why it matters]
- `path/to/other.ext` — [what gets touched]

**Acceptance**:
- [observable criterion 1]
- [observable criterion 2]

**Verify**:
\`\`\`bash
[exact command(s) — build, test, or both]
\`\`\`

**Tier hint**: [Prose advice — "Haiku candidate, pure renaming"; "Sonnet, multi-file but no design decisions"; "needs Opus to scope"]

**Context** (only if non-obvious): [Hidden constraints, prior decisions, or surrounding patterns. Skip if everything is clear from the files.]
```

## Authoring rules

1. **Read the files first.** Verify paths exist, capture line numbers, understand surrounding patterns. An entry pointing at code you didn't read is worse than no entry.
2. **One value-delivering unit per entry.** If the work has natural seams, write multiple entries instead of one giant one.
3. **Acceptance must be observable.** "Code is cleaner" isn't acceptance; "function returns `Result<T, E>` instead of `T | null`" is. The next agent must be able to read acceptance criteria and know unambiguously whether they're done.
4. **Verify must be a command.** Don't say "run the tests" — say `npm test -- foo.spec.ts`. The receiving agent should be able to copy-paste it.
5. **Tier hint is prose advice, not gating.** The user runs single-agent-at-a-time; any agent can pick up any item. The hint just helps match work to model so cheap models aren't asked to make design calls.
6. **Inline only the non-obvious.** If a pattern is visible from reading the file, don't restate it. If there's a hidden invariant ("this function is also called from the worker thread, must stay sync"), call it out.
7. **No `[~]` claim markers.** Single-agent workflow; first agent to start an item executes it.

## After drafting

1. Show the proposed entry to the user before appending. Use a fenced code block so they can read and edit easily.
2. Ask "Append as-is, revise, or discard?"
3. On approval, append to `.docs/ai/roadmap.md` under the existing `## Backlog` section. If no Backlog section exists, create one between the Milestones section and the Constraints section.
4. Commit the roadmap change with a message like `roadmap: add backlog item — [title]`.

## Failure modes to avoid

- **Vague scope**: "Improve error handling in API client". A receiving agent has nothing concrete to do. Force yourself to pick the specific fix.
- **Missing verify**: Without a command, the agent has no signal for done. Always include one.
- **Over-scoping**: Bundling 3 unrelated fixes into one entry creates merge conflicts and partial completions. Split.
- **Stale file refs**: Line numbers shift over time. If you author an entry today and it sits in the backlog for a month, line ranges may be stale. Mention class/function names alongside line numbers so a refresh `grep` can re-anchor it.
- **Borrowing context**: Don't write "as we discussed in this conversation". The receiving agent doesn't have that context. Inline what they need.
