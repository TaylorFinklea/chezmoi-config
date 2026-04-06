# Audit Backlog

## Purpose

Scan the current repo for technical debt and quality issues, then append actionable Haiku and Sonnet backlog items to `.docs/ai/roadmap.md`.

## Inputs

- `.docs/ai/roadmap.md` or `docs/ai/roadmap.md`
- recent git history
- source files and project manifests

## Required behavior

1. Find the roadmap and read the existing `## Backlog` section.
2. Preserve the current `tier3_owner` value. Do not change architect ownership unless the user explicitly requests it.
3. Detect the project type from manifests and directory layout.
4. Scan for low-risk, independent backlog candidates.
5. Add only Haiku and Sonnet items.
6. Include enough detail for a fresh agent to act without asking follow-up questions.
7. Avoid duplicates and avoid recently completed work.

## Output format

Append backlog items under the correct heading using:

```markdown
- [ ] [description] (file:line)
```

Cap the audit so it stays actionable:

- at most 10 Haiku items
- at most 6 Sonnet items

## Owner rules

- `audit-backlog` never creates or executes Opus work directly.
- It may preserve existing Opus content.
- It may be used regardless of the current `tier3_owner`.

## Verification and commit

- Re-read the final roadmap section after edits.
- Commit the roadmap update with a docs-focused message.
- Do not push automatically.
