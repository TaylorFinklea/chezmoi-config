# Roadmap

Durable goals and milestones for this repo. Update when scope changes, not every session.

## Vision

Keep personal dotfiles and AI-agent configuration aligned across Claude, Codex, and GitHub Copilot CLI through one tracked chezmoi source of truth.

## Milestones

### M1: Cross-agent AI workflow parity
- [x] Add repo-local AI handoff docs under `.docs/ai/`
- [x] Make Opus/T3 architect ownership vendor-neutral
- [x] Add a managed GitHub Copilot CLI instruction surface alongside Claude and Codex
- [x] Normalize the shared workflow command set to `audit-backlog`, `process-backlog`, `process-backlog-opus`, and `resume-and-continue`
- [x] Add canonical workflow docs under `docs/` and align Claude, Codex, Copilot, and generic skills to them
- [x] Add a reviewed import workflow so home-directory AI changes are classified for safety before they are synced back into this repo

### M2: Downstream project adoption
- [ ] Apply the owner-neutral roadmap template to active project repos managed from this machine
- [ ] Validate a full owner switch in a real project with Claude, Codex, and Copilot CLI

<!-- Acceptance criteria guidance:
     Good milestone items include verifiable criteria, not just descriptions.
     Examples:
       - [ ] Apply owner-neutral roadmap template to >=1 active project — verified by `grep tier3_owner` in that project's roadmap
       - [ ] Validate a full owner switch — verified by Codex successfully running /process-backlog-opus after tier3_owner is changed from claude to codex
     Bad:
       - [ ] Set up roadmap in other repos
       - [ ] Test owner switching
     The difference: good items say what "done" looks like and how to check it.
-->

## Backlog (parallel, tiered by model capability)

<!-- tier3_owner: unassigned -->
<!-- Valid values: claude, codex, copilot, unassigned -->
<!-- Populate during milestones or audits. Include file paths. Items must be independent. -->

### Haiku (mechanical, no judgment)
<!-- Empty catch blocks, a11y labels, doc comments, linter fixes, hardcoded values -->

### Sonnet (some architectural judgment)
<!-- View refactoring, utility extraction, type safety, component extraction -->

### Opus (design skill, cross-cutting — owned by tier3_owner)
<!-- Unit tests, integration tests, API design, complex refactors -->

## Priority Order

- Finish validating the owner-neutral contract in downstream repos before adding more AI-tool-specific automation.

## Constraints

- The roadmap owner field must stay backward compatible with existing `tier3_owner` metadata.
- Copilot support must use official GitHub instruction surfaces rather than an invented file format.
