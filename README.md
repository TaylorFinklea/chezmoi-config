# Chezmoi Dotfiles Configuration

This directory contains dotfile configurations managed by [chezmoi](https://www.chezmoi.io/).

## Why Chezmoi?

Chezmoi is used because it:
- Doesn't require admin/root privileges
- Works on managed work computers
- Manages dotfiles with templating, encryption, and scripts
- Supports multiple machines with different configurations

## Installation

### 1. Install Chezmoi

```bash
# Using Homebrew (recommended for macOS)
brew install chezmoi

# Or using the install script
sh -c "$(curl -fsLS get.chezmoi.io)"
```

### 2. Run the installation script

```bash
cd ~/git/chezmoi-config
./scripts/install.sh
```

This will:
- Install chezmoi if needed
- Initialize your dotfiles
- Write `~/.config/chezmoi/chezmoi.toml` so `chezmoi update` points at this clone
- Ask for the explicit `ai_profile` for this machine (`work` or `personal`)
- Optionally install packages

**Or do it manually:**

```bash
# If this is your first time setting up chezmoi with this config
cd ~/git/chezmoi-config
chezmoi init --source=$PWD

# Keep chezmoi update pointed at this clone
mkdir -p ~/.config/chezmoi
cat > ~/.config/chezmoi/chezmoi.toml <<EOF
sourceDir = "$PWD"

[update]
    apply = true
    recurseSubmodules = true

[data]
    ai_profile = "personal"
EOF

# Apply the dotfiles
chezmoi apply -v
```

### 3. Install Homebrew packages (macOS)

```bash
# Work configuration (excludes Zed, Bruno, Ollama, Voiceink)
cd ~/git/chezmoi-config
./scripts/install-homebrew-work.sh

# OR Personal configuration (full suite)
./scripts/install-homebrew-personal.sh
```

**Note:** To update your app list later, edit the script and re-run it. It won't reinstall existing packages.

### 4. Install VS Code extensions (Optional)

```bash
cd ~/git/chezmoi-config
./scripts/install-vscode-extensions.sh
```

---

## Daily Usage

After initial setup, you typically only need:

```bash
chezmoi update    # Update dotfiles (pull from git + apply)
```

To update installed apps, run the Homebrew script again after editing it.

`chezmoi update` works because this repo manages `~/.config/chezmoi/chezmoi.toml` with the active `sourceDir`. If that file is missing or points at a deleted path, re-run `./scripts/install.sh` or `chezmoi init --source=$HOME/git/chezmoi-config --force`.

## OpenAI API Key

`OPENAI_API_KEY` is loaded by `zsh` and `fish` from the macOS Keychain. Do not store the actual key in this repo.

Set or update it locally with:

```bash
security add-generic-password -U -a "$USER" -s OPENAI_API_KEY -w 'your-api-key-here'
```

After saving it, start a new `zsh` or `fish` shell so the variable is exported automatically.

## GitHub PAT

`GITHUB_PAT_TOKEN` is loaded by `zsh` and `fish` from the macOS Keychain, and a LaunchAgent loads the same value into the `launchd` environment for GUI-launched tools. Do not store the actual PAT in this repo.

Set or update it locally with:

```bash
security add-generic-password -U -a "$USER" -s codex-github-pat -w 'your-github-pat-here'
```

This repo expects:
- Keychain service: `codex-github-pat`
- Environment variable: `GITHUB_PAT_TOKEN`

After saving it:
- Open a new `zsh` or `fish` shell so the shell variable is exported automatically.
- Run `~/.local/bin/load-codex-github-pat` if you want to load it into `launchd` immediately without logging out.

Useful checks:

```bash
security find-generic-password -a "$USER" -s codex-github-pat -w
echo $GITHUB_PAT_TOKEN
launchctl getenv GITHUB_PAT_TOKEN
```

## AI Agent Surfaces

This repo manages instruction and skill surfaces for Claude Code, Codex, GitHub Copilot CLI, and Opencode. The overlay is deliberately thin — vanilla harness behavior plus a small shared handoff layer.

Per-tool files this repo distributes:
- `AGENTS.md` — shared cross-agent instructions (canonical instruction file going forward)
- `CLAUDE.md` — Claude Code overrides; thin pointer to AGENTS.md plus Claude-specific tool mappings
- `dot_codex/AGENTS.md` — Codex home-level defaults
- `dot_copilot/copilot-instructions.md` — GitHub Copilot CLI defaults
- `dot_config/opencode/opencode.json.tmpl` — Opencode global config
- `dot_config/tmuxai/config.yaml.tmpl` — TmuxAI model/provider config
- `dot_claude/skills`, `dot_codex/skills`, `dot_copilot/skills`, `dot_agents/skills` — aligned skills (LSPs, language helpers, planning utilities)
- `.mcp.json` — repo-scoped MCP servers
- `dot_codex/private_config.toml.tmpl` and `.chezmoitemplates/codex/*.toml` — Codex MCP/server config
- `dot_copilot/mcp-config.json.tmpl` — Copilot CLI MCP servers
- `.chezmoidata/ai.json` — shared MCP scope metadata

Per-repo handoff lives in `.docs/ai/`:
- `roadmap.md` — milestones, Now/Next/Later, self-contained backlog entries
- `current-state.md` — last session summary
- `decisions.md` — append-only ADR log
- `phases/` — optional `<slug>-spec.md` / `<slug>-report.md` pairs for substantial multi-session work
- `handoff-template.md` — checklist format

Sync strategy:
- Edit repo-managed docs and skills here; distribute with `chezmoi apply`.
- `~/.codex/config.toml`, `~/.copilot/mcp-config.json`, and `~/.config/opencode/opencode.json` are profile-managed via `ai_profile`, not mirrored from a single machine.
- `~/.config/tmuxai/config.yaml` exposes `codex` and `copilot` model profiles for `tmuxai`.
- Detect drift between home and repo with `chezmoi diff`; reconcile manually rather than running an importer.

## Shared MCP Servers

This repo manages MCP fanout in two layers:

- `shared` servers in `.chezmoidata/ai.json` render into the managed home configs for Codex, GitHub Copilot CLI, and OpenCode.
- `personal-only` servers in `.chezmoidata/ai.json` render only when `data.ai_profile = "personal"`.
- Claude Code currently uses the repo-scoped [`.mcp.json`](./.mcp.json) while working in this repo.

Today the managed surfaces include:

- `chrome-devtools` across Codex, Copilot, OpenCode, and the repo-scoped Claude Code config.
- `supabase-personal`, `flyctl`, and `railway` on personal Codex/OpenCode renders, plus the repo-scoped Claude Code config in this repo.

The personal Supabase entry is named `supabase-personal` instead of `supabase` so it does not collide with the plugin-bundled `supabase` server from the personal `build-web-apps` Codex plugin.

## Directory Structure

```
chezmoi/
├── README.md                     # This file
├── dot_zshrc                     # ~/.zshrc
├── dot_zshenv                    # ~/.zshenv
├── dot_config/                   # ~/.config/
│   ├── starship.toml            # Starship prompt config
│   ├── fish/                    # Fish shell config
│   │   └── config.fish
│   ├── atuin/                   # Atuin shell history
│   │   └── config.toml
│   ├── ghostty/                 # Ghostty terminal
│   │   └── config
│   ├── zellij/                  # Zellij terminal multiplexer
│   │   ├── config.kdl
│   │   ├── layouts/
│   │   └── themes/
│   ├── nvim/                    # Neovim configuration
│   └── ...
├── scripts/                     # Helper scripts
│   ├── install.sh               # Bootstrap + chezmoi init/apply
│   ├── install-essentials.sh    # Minimal CLI tools
│   ├── install-homebrew-work.sh # Work package set
│   └── install-homebrew-personal.sh # Personal package set
└── .chezmoiignore               # Files to ignore
```

## Chezmoi Naming Conventions

Chezmoi uses special prefixes for file/directory names:

- `dot_` → `.` (hidden files)
- `private_` → file with 0600 permissions
- `executable_` → file with executable permissions
- `symlink_` → create a symlink
- `.tmpl` suffix → template file (processed with Go templates)

Examples:
- `dot_zshrc` → `~/.zshrc`
- `dot_config` → `~/.config`
- `private_dot_ssh` → `~/.ssh` (with 0700 permissions)
- `executable_dot_local/bin/script.sh` → `~/.local/bin/script.sh` (executable)

## Included Configurations

### Shell Configuration
- ✅ Zsh with auto-suggestions and syntax highlighting
- ✅ Fish shell with vi key bindings and custom functions
- ✅ Starship prompt
- ✅ Atuin shell history
- ✅ Shell aliases and environment variables

### Development Tools
- 📦 Installed via Homebrew (see `scripts/install-homebrew-work.sh` and `scripts/install-homebrew-personal.sh`)
  - Git, gh (GitHub CLI)
  - Python (uv, pyenv)
  - Node.js (nvm, pnpm)
  - Rust (rustup)
  - Go, Lua, Swift, Zig

### Editor Configuration
- ✅ VS Code settings and keybindings
- 📦 VS Code extensions (see `vscode-extensions.txt`)
- ✅ Neovim (LazyVim)

### Terminal Applications
- ✅ Zellij (terminal multiplexer)
- ✅ Ghostty (terminal emulator)
- ✅ Neovim
- ✅ Xplr (file explorer)
- ✅ Yazi, Ranger, NNN (file managers)

### System Utilities
- 📦 Installed via Homebrew
  - ripgrep, fd, fzf
  - zoxide (smart cd)
  - jq, yq
  - htop, btop, glances

## Common Chezmoi Commands

```bash
# Update dotfiles from git and apply changes
chezmoi update

# Check what would change (without applying)
chezmoi diff

# Apply changes manually
chezmoi apply -v

# Edit a file with your editor
chezmoi eVS Code settings
chezmoi add ~/Library/Application\ Support/Code/User/settings.json

# Export current VS Code extensions
/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code --list-extensions > ~/git/chezmoi-config/vscode-extensions.txt

# Update dit ~/.zshrc

# Add a new file to chezmoi
chezmoi add ~/.config/newapp/config.toml

# Update chezmoi from source directory
chezmoi re-add
```

## Template Variables

Chezmoi supports templates using Go's text/template syntax. Create a `.chezmoi.toml.tmpl` file to define variables:

```toml
[data]
    email = "your.email@example.com"
    name = "Your Name"
```

Then use in templates:
```bash
# In dot_gitconfig.tmpl
[user]
    name = {{ .name }}
    email = {{ .email }}
```

## Updating Configurations

1. Edit files in `~/git/chezmoi-config/`
2. Preview changes: `chezmoi diff`
3. Apply locally: `chezmoi apply -v`
4. Commit and push to git
5. On other machines: `chezmoi update`

## Troubleshooting

### Check current state
```bash
chezmoi status
chezmoi diff
```

### Fix `chezmoi update` if it points at a missing source directory
```bash
cd ~/git/chezmoi-config
chezmoi init --source=$PWD --force
chezmoi apply -v
```

### Verify what chezmoi would do
```bash
chezmoi apply --dry-run -v
```

### Reset a file to repository state
```bash
chezmoi apply --force ~/.zshrc
```

### Re-add a file from home directory
```bash
chezmoi add ~/.config/starship.toml
```

## Links

- [Chezmoi Documentation](https://www.chezmoi.io/)
- [Chezmoi Quick Start](https://www.chezmoi.io/quick-start/)
- [Chezmoi User Guide](https://www.chezmoi.io/user-guide/command-overview/)
