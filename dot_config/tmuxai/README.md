# TmuxAI

This repo manages `~/.config/tmuxai/config.yaml`.

Configured models:

- `codex` — OpenAI Responses API using `${OPENAI_API_KEY}`
- `copilot` — GitHub Copilot provider using `${GITHUB_PAT_TOKEN}`

Notes:

- TmuxAI's upstream provider set supports `github-copilot` directly, but not a dedicated Codex CLI subprocess provider. The `codex` profile here uses the OpenAI provider with a Codex model name instead.
- From inside TmuxAI, use `/model` to list profiles and `/model codex` or `/model copilot` to switch.
- The tmux config in this repo adds popup launchers for both profiles from the current pane directory.
