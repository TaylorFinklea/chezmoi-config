---
description: Verify implementation against a spec
argument-hint: [spec-path]
---

Use the `spec-verifier` agent to verify the current implementation against this spec:

`$ARGUMENTS`

If agent invocation is not available in this context, follow the `spec-verifier` behavior yourself:

- Read repo instructions, the spec, recent commits, `git status`, and the relevant diff.
- Map every acceptance criterion to evidence or a concrete gap.
- Run the spec's verification commands when safe.
- Do not change product code unless explicitly asked.
- Write or update the phase report when verification itself is the deliverable.
- Return a Pass, Partial, or Fail verdict with evidence and residual risk.
