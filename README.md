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
- Auto-detect work vs personal computer
- Optionally install packages

**Or do it manually:**

```bash
# If this is your first time setting up chezmoi with this config
cd ~/git/chezmoi-config
chezmoi init --source=$PWD

# Apply the dotfiles
chezmoi apply -v
```

### 3. Install Homebrew packages (macOS)

```bash
# Work configuration (excludes Zed, Insomnia, Bruno, Ollama, Voiceink)
cd ~/git/chezmoi-config
./scripts/install-homebrew-work.sh

# OR Personal configuration (full suite)
./scripts/install-homebrew-personal.sh
```

**Note:** To update your app list later, edit the script and re-run it. It won't reinstall existing packages.

---

## Daily Usage

After initial setup, you typically only need:

```bash
chezmoi update    # Update dotfiles (pull from git + apply)
```

To update installed apps, run the Homebrew script again after editing it.

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
# Check what would change
chezmoi diff

# Apply changes
chezmoi apply -v

# Edit a file with your editor
chezmoi edit ~/.zshrc

# Add a new file to chezmoi
chezmoi add ~/.config/newapp/config.toml

# Update chezmoi from source directory
chezmoi re-add

# Pull and apply changes from git
cd ~/git/chezmoi-config
git pull
chezmoi apply -v
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
2. Test changes: `chezmoi diff`
3. Apply locally: `chezmoi apply -v`
4. Commit to git
5. On other machines: `cd ~/git/chezmoi-config && git pull && chezmoi apply -v`

## Troubleshooting

### Check current state
```bash
chezmoi status
chezmoi diff
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
