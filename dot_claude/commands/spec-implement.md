---
description: Implement an approved spec
argument-hint: [spec-path]
---

Use the `spec-implementer` agent to implement this approved spec:

`$ARGUMENTS`

If agent invocation is not available in this context, follow the `spec-implementer` behavior yourself:

- Require a spec path or clearly pasted spec before changing code.
- Read repo instructions, current handoff state, the full spec, and referenced files.
- Implement only the spec. Do not re-plan or expand scope.
- Run the verification commands from the spec.
- Update handoff docs and the phase report when appropriate.
- Create a small local commit. Do not push.
