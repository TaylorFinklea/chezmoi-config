---
name: init-ai-docs
description: Bootstrap .docs/ai/ handoff state and optionally docs/ai-workflows/ in a new project repo.
disable-model-invocation: true
---

# Initialize AI Docs

Bootstrap the shared AI handoff and workflow docs in the current project repo.

## What to do

1. **Check if `.docs/ai/` already exists.** If it does, report what's there and
   ask before overwriting. Never silently overwrite existing handoff state.

2. **Create `.docs/ai/` from templates.** Copy each file from
   `~/.agents/templates/handoff/` into `.docs/ai/`:
   - `roadmap.md`
   - `current-state.md`
   - `next-steps.md`
   - `decisions.md`
   - `handoff-template.md`

3. **Create `.docs/ai/phases/`** with a README:
   ```
   # Phase Execution Artifacts
   Specs and reports for the phase execution protocol.
   See docs/ai-workflows/phase-execution.md for the full protocol.
   ```

4. **Ask whether to also bootstrap `docs/ai-workflows/`.** If yes, copy each
   file from `~/.agents/templates/workflows/` into `docs/ai-workflows/`:
   - `phase-execution.md`
   - `process-backlog.md`
   - `process-backlog-opus.md`
   - `resume-and-continue.md`
   - `audit-backlog.md`

5. **Commit** the new docs with a message like
   `docs: bootstrap .docs/ai/ handoff state and workflow docs`.

6. **Report** what was created and suggest next steps:
   - Fill in the Vision and Milestones in `roadmap.md`
   - Set `tier3_owner` in the roadmap if using the tiered backlog
