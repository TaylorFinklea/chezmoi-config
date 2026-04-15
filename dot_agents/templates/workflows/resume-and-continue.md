# Resume And Continue

## Purpose

Resume work after prior AI-agent activity, review recent changes, assess roadmap state, and continue only if the active tool is allowed to own the next architect-level phase.

## Inputs

- `.docs/ai/roadmap.md` or `docs/ai/roadmap.md`
- `.docs/ai/current-state.md`
- `.docs/ai/next-steps.md`
- recent git history

## Required behavior

1. Read the roadmap and current `tier3_owner`.
2. Inspect recent commits and determine whether another agent recently changed the repo.
3. Review the changed files and verify they align with the roadmap.
4. Run the repo verification/build command when recent agent changes need validation.
5. Update roadmap state to reflect completed work or issues discovered during review.

## Continue rules

- If the active tool matches `tier3_owner`, it may continue the next Opus phase after review.
- If the active tool does not match `tier3_owner`, it must stop after summarizing state and report which tool owns the next Opus phase.
- If `tier3_owner: unassigned`, it must stop after summarizing state and report that ownership must be assigned before Opus work continues.

## Planning behavior

If roadmap work is running low, the active owner may plan new Opus work. Planning must preserve the current owner unless the user explicitly asks to switch architect ownership.

## Output

Report:

- commits reviewed
- issues found
- verification result
- whether the active tool may continue architect-level work
