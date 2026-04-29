---
description: Write a product and implementation spec
argument-hint: [slug-or-goal]
---

Use the `spec-planner` agent for this request:

`$ARGUMENTS`

If agent invocation is not available in this context, follow the `spec-planner` behavior yourself:

- Read repo instructions and `.docs/ai/` handoff state before asking questions.
- Inspect the relevant files and configs.
- Ask only for product intent or tradeoffs that cannot be discovered.
- Write a decision-complete spec with product overview, implementation plan, interfaces, edge cases, test plan, and handoff tier.
- Prefer `.docs/ai/phases/<slug>-spec.md` when the repo uses `.docs/ai/`.
- Do not change product code.
