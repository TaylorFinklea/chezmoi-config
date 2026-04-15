# Phase Execution Protocol

## Purpose

Provide a structured execution flow for substantial work — milestone sub-items,
Opus-tier backlog items, and ad-hoc tasks that span multiple files or involve
design decisions. Ensures each piece of work is planned, clarified, built,
verified, and reported in a way that survives session boundaries.

## When this protocol applies

- Milestone sub-items (M1, M2, etc.)
- Opus-tier backlog items
- Ad-hoc work that touches multiple files or requires design decisions

This protocol does **not** apply to:

- Haiku-tier backlog items (use `/process-backlog`)
- Sonnet-tier backlog items (use `/process-backlog`)
- Single-file mechanical fixes
- Questions or read-only investigations

## Inputs

- `.docs/ai/roadmap.md` — milestones and backlog
- `.docs/ai/current-state.md` — last session context
- `.docs/ai/next-steps.md` — queued actions
- `.docs/ai/decisions.md` — prior architectural decisions
- `.docs/ai/phases/` — prior phase specs and reports (if any exist)
- The work item description (from roadmap, user request, or both)

---

## Phase 1: Plan

**Entry criteria:**
1. The work item is identified and falls within protocol scope.
2. The agent has read all handoff state files.

**Actions:**
1. Read relevant source files to understand the current state.
2. Read any prior phase specs/reports in `.docs/ai/phases/` to re-establish
   cross-session context.
3. Draft a lightweight spec (see template below) covering:
   - Goal, scope, approach, acceptance criteria, assumptions, out of scope.
4. Write the spec to `.docs/ai/phases/<item-slug>-spec.md`.
5. Present the spec to the user and wait for a response before proceeding.

**Exit criteria:**
1. The spec file exists on disk.
2. The user has seen the spec. Any response other than explicit rejection
   counts as approval to proceed.

## Phase 2: Clarify

**Entry criteria:**
1. The spec has been presented and not rejected.

**Actions:**
1. Identify open questions and ambiguities in the spec.
2. Present questions using **structured-first** format:
   - Default to enumerated options with brief rationale for each.
   - Fall back to free-form only for genuinely open-ended questions
     (e.g., naming, branding, unconstrained preferences).
   - Batch 2–4 related questions per prompt. Do not ask one at a time
     unless the questions are truly independent.
3. If no questions remain, skip directly to Build.
4. Update the spec file with answers and resolved ambiguities.

**Exit criteria:**
1. All questions that could affect scope, data model, UX, or architecture
   are answered.
2. The spec file reflects the resolved decisions.

## Phase 3: Build

**Entry criteria:**
1. The spec is finalized (all clarifications resolved or none needed).

**Actions:**
1. Implement according to the spec, in the order listed.
2. Make small, descriptive commits as work progresses.
3. For mid-build decisions:
   - **Stop and ask** if the decision could affect UX, data model, or
     architecture.
   - **Log and continue** for small incidental decisions (e.g., variable
     naming, import ordering). Log these in the phase report, not in
     `decisions.md`.
4. If the scope needs to change materially, return to Phase 1 and update
   the spec before continuing.

**Exit criteria:**
1. All spec steps are implemented.
2. All code is committed.

## Phase 4: Verify

**Entry criteria:**
1. Build is complete.

**Actions:**
1. Run automated checks where available:
   - Syntax validation (linters, parsers, template rendering)
   - Build commands (project-specific: `npm test`, `cargo test`, etc.)
   - Config validation (`jq empty`, YAML parsing, `bash -n`, etc.)
2. For anything requiring a running environment or manual testing, produce
   a **specific** checklist — not a vague "test it" instruction. Each item
   should say what to do and what the expected result is.
3. If verification fails, fix the issue and re-verify. If the fix changes
   scope, return to Phase 1.

**Exit criteria:**
1. All automated checks pass.
2. A manual verification checklist exists (if applicable).

## Phase 5: Report

**Entry criteria:**
1. Verification is complete.

**Actions:**
1. Write the phase report to `.docs/ai/phases/<item-slug>-report.md`
   (see template below).
2. Update the existing handoff docs:
   - `.docs/ai/current-state.md` — add session summary covering this work.
   - `.docs/ai/next-steps.md` — remove completed items, add follow-ups.
   - `.docs/ai/decisions.md` — append entries for any non-obvious decisions.
3. If the item came from the roadmap backlog, mark it `[x]` in `roadmap.md`.
4. Commit the phase report and handoff doc updates together.

**Exit criteria:**
1. Phase report file exists on disk.
2. Handoff docs are updated.
3. Roadmap item is marked complete (if applicable).

---

## Interaction with the backlog claim protocol

- When working an Opus backlog item through this protocol, claim it (`[~]`)
  at Phase 1 (Plan), not Phase 3 (Build). This gives other agents early
  visibility that architect-level work is in progress.
- If the protocol is abandoned mid-way, revert to `[ ]` and add a
  `<!-- phase-abandoned: YYYY-MM-DD [reason] -->` comment.
- `/process-backlog-opus` should invoke this protocol for each Opus item.
  `/process-backlog` for Haiku/Sonnet items is unchanged.

## Session boundary rules

- Each phase may run in a separate session.
- All continuity comes from filesystem artifacts — never from chat history.
- A session starting at phase N must orient entirely from the root
  instruction file (`CLAUDE.md` / `AGENTS.md`) plus `.docs/ai/` files,
  including `.docs/ai/phases/<item-slug>-spec.md`.
- A spec file without a matching report means the previous session was
  mid-protocol. Resume at the appropriate phase rather than starting fresh.

---

## Spec template

```markdown
# Phase Spec: <item title>

**Goal:** <one sentence>
**Roadmap item:** <reference or "ad-hoc">
**Date:** <YYYY-MM-DD>

## Scope
- Create: <files>
- Modify: <files>
- Delete: <files>

## Approach
1. <step>
2. <step>

## Acceptance criteria
- [ ] <criterion — says what "done" looks like and how to check it>

## Assumptions
- <assumption>

## Out of scope
- <exclusion>

## Open questions
- <resolved or pending>
```

## Report template

```markdown
# Phase Report: <item title>

**Date:** <YYYY-MM-DD>
**Outcome:** <pass | fail | partial>
**Spec:** `.docs/ai/phases/<item-slug>-spec.md`

## Changes
- <file>: <what changed>

## Decisions made
- <decision and rationale>

## Verification results

<automated check output or "no automated checks available">

### Manual verification checklist
- [ ] <what to do — expected result>

## Follow-up items
- [ ] <next-steps or backlog candidates>

## Context for next phase
<anything the next session needs to know that isn't captured elsewhere>
```
