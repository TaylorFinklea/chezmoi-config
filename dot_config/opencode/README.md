# OpenCode Global Config

This directory is managed by chezmoi and renders to `~/.config/opencode/`.

The generated `opencode.json` is assembled from the shared AI config catalog in
`.chezmoidata/ai.json` and filtered by the local `ai_profile` value.

This repo also manages global OpenCode agents and commands:

- `agents/spec-planner.md` plus `/spec-plan` for product and technical specs
- `agents/spec-implementer.md` plus `/spec-implement` for approved spec execution
- `agents/spec-verifier.md` plus `/spec-verify` for acceptance and verification checks

Agent files intentionally omit fixed model IDs so each session or project can choose the
right planning, implementation, or mechanical verification tier.
