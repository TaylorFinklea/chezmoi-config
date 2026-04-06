---
name: resume-and-continue
description: Resume after other AI agents worked on the repo. Review their changes in a background subagent while starting the next Opus-tier phase. If the roadmap is running low on items, start a planning session with structured questions instead.
user-invocable: true
disable-model-invocation: true
---

# Resume and Continue

Pick up where other AI agents left off. Review their work in the background while you advance the next phase.

## Step 1: Assess the Situation

1. Read `.docs/ai/roadmap.md` (or the unified roadmap if the repo references one in another repo).
2. Run `git log --oneline -15` in each repo to see recent commits.
3. Count:
   - **Uncommitted phase items** — unchecked items under the current active phase (M2, M3, etc.)
   - **Uncommitted backlog items** — unchecked items in the Backlog section
   - **Recent non-Claude commits** — commits without "Co-Authored-By: Claude" in the last 15

## Step 2: Branch Based on State

### If there are recent non-Claude commits → Review + Work in Parallel

**In parallel** (single message, two tool calls):

**A. Background subagent: Review external agent work**

Spawn a background Agent (general-purpose) with this prompt:

> You are reviewing work done by an external AI agent on this repo. Check for correctness and completeness.
>
> 1. Run `git log --oneline -10` to see recent commits.
> 2. For each commit NOT authored by Claude, run `git show <sha>` to read the diff.
> 3. For each change, verify:
>    - Does the code compile / look syntactically correct?
>    - Does it match what the roadmap item described?
>    - Are there leftover local declarations that should have been removed (common with extract-to-shared refactors)?
>    - Any obvious bugs, missing imports, or broken patterns?
> 4. Run the build command from CLAUDE.md to verify compilation.
> 5. Update `.docs/ai/roadmap.md` — mark completed items with strikethrough (~text~).
> 6. Report: list of commits reviewed, issues found (if any), build result.

**B. Start the next Opus-tier phase** (see "Work on Next Phase" below)

### If the roadmap is running low → Planning Session

"Running low" means: fewer than 3 unchecked phase items AND fewer than 5 unchecked backlog items total.

Do NOT start coding. Instead, run a planning session:

1. Read the current roadmap, current-state, and next-steps docs.
2. Summarize what's been accomplished and what's left.
3. Use `AskUserQuestion` with structured options (select or multiSelect) to determine direction. Ask about:
   - **Product priorities**: Which features matter most next? (multiSelect with 3-4 concrete options)
   - **Phase sequencing**: What should the next phase focus on? (select with 2-3 options + descriptions)
   - **Backlog audit**: Should we audit the codebase for new tech debt items? (select: yes/no/specific area)
   - **Scope changes**: Any new constraints, deadlines, or pivots? (select with common options + Other)
4. Based on answers, draft new phase items and backlog items.
5. Use another round of `AskUserQuestion` if needed to refine.
6. Update the roadmap and commit.

**Key rule for planning sessions**: Always use `AskUserQuestion` with `options` arrays (select or multiSelect). Do not ask raw text questions for product direction — give concrete choices the user can pick from. Save raw text questions for clarifying specific technical details.

### If there are no external commits and plenty of work → Just Work

Skip the review subagent. Go directly to "Work on Next Phase."

## Work on Next Phase

1. Identify the current active phase (first non-complete phase in the roadmap).
2. Read `.docs/ai/next-steps.md` for the immediate action items.
3. Pick the first unchecked item in the phase.
4. Begin implementation. Follow the repo's CLAUDE.md for build commands, coding patterns, and commit expectations.
5. After completing work, update handoff docs.

## After the Review Subagent Returns

When the background review agent completes:

1. Read its report.
2. If it found issues:
   - Fix them before continuing phase work (or dispatch a fix subagent).
   - Do not ignore review findings.
3. If the build failed:
   - Stop phase work and fix the build first.
4. If everything is clean:
   - Note it briefly and continue.
