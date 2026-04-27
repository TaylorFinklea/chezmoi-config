---
name: init-ai-docs
description: Bootstrap a slim `.docs/ai/` handoff state in a new project repo.
---

# Initialize AI Docs

Bootstrap a lightweight handoff layer for the current project repo. Intentionally minimal — no protocol scaffolding, no claim markers, no cross-tool sync.

## What to do

1. **Check if `.docs/ai/` already exists.** If it does, report what's there and ask before overwriting. Never silently overwrite existing handoff state.

2. **Create `.docs/ai/` from templates.** Copy each file from `~/.claude/templates/handoff/` into `.docs/ai/`:
   - `roadmap.md`
   - `current-state.md`
   - `decisions.md`
   - `handoff-template.md`

3. **Create `.docs/ai/phases/`** with a README:
   ```
   # Phase Artifacts

   Lightweight specs and reports for substantial multi-session work.
   `<slug>-spec.md` before, `<slug>-report.md` after. Skip for routine changes.
   ```

4. **Commit** with a message like `docs: bootstrap .docs/ai/ handoff state`.

5. **Report** what was created and suggest next steps:
   - Fill in the Vision in `roadmap.md`
   - Add active items under Now / Next / Later
   - Add a project-level `AGENTS.md` if one doesn't exist (canonical instruction file)
