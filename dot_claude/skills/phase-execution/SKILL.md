---
name: phase-execution
description: Follow the Plan/Clarify/Build/Verify/Report protocol for milestone sub-items, Opus-tier backlog work, and substantial ad-hoc tasks.
user-invocable: true
disable-model-invocation: true
---

# Phase Execution Protocol

Follow the canonical workflow in `../../../docs/ai-workflows/phase-execution.md`.

Claude-specific notes:

- Use `AskUserQuestion` with `options` for structured clarification prompts during Phase 2 (Clarify). Fall back to free-form for genuinely open-ended questions.
- Use `TaskCreate` / `TaskUpdate` to track phase progress (one task per phase step).
- Present the spec inline in the conversation rather than directing the user to open the file.
- Phase specs and reports go to `.docs/ai/phases/`.
