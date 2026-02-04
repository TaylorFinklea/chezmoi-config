# Migration Summary

## From home-manager to chezmoi

**Migration Date:** February 4, 2026  
**Source:** `nixos-config/home/work.nix` and related files  
**Destination:** `nixos-config/chezmoi/`

---

## ✅ Successfully Migrated

### Shell Configuration
- ✅ **Zsh configuration** (`~/.zshrc`)
  - Auto-suggestions
  - Syntax highlighting (with custom colors)
  - History settings
  - Completion system
  - All aliases and functions

- ✅ **Fish shell configuration** (`~/.config/fish/config.fish`)
  - Vi key bindings with cursor shapes
  - Custom key bindings (Ctrl+F, Alt+F)
  - All aliases and functions
  - Pure theme color settings
  
- ✅ **Environment variables** (`~/.zshenv`)
  - PATH configurations
  - PYTHONPATH
  - Homebrew initialization
  
### CLI Tools & Prompts
- ✅ **Starship prompt** (`~/.config/starship.toml`)
  - Tokyo Night color palette
  - Custom format string
  - All language indicators
  - OS symbols
  
- ✅ **Atuin shell history** (`~/.config/atuin/`)
  - Configuration file
  - Ayu theme
  - Tokyo Night theme
  - Sync settings
  
### Application Configurations
- ✅ **Zellij** (`~/.config/zellij/`)
  - Main config (config.kdl)
  - Themes directory
  - Layouts directory
  
- ✅ **Ghostty** (`~/.config/ghostty/`)
  - Terminal configuration
  
- ✅ **Neovim** (`~/.config/nvim/`)
  - Full Neovim configuration
  
- ✅ **Xplr** (`~/.config/xplr/`)
  - File explorer configuration

### Package Management
- ✅ **Homebrew installation script** (`home/work/homebrew.sh`)
  - All casks (GUI applications)
  - All formulae (CLI tools)
  - Taps configuration
  - Already created and functional

---

## 📦 Package Installation Method Changed

### Package Installation Method Changed

### Previously (home-manager/Nix)
```nix
home.packages = with pkgs; [ ripgrep fd jq ... ];
```

### Now (Homebrew)
```bash
# Work computer (minimal professional tools)
./scripts/install-homebrew-work.sh

# Personal computer (full suite)
./scripts/install-homebrew-personal.sh

# Or just essentials
./scripts/install-essentials.sh
```

### Package Categories in Homebrew Script

**Development Tools:**
- Languages: Python (pyenv, uv), Node.js (nvm, pnpm), Rust, Go, Lua, Swift, Zig
- Tools: Git, gh, tmuxinator, jupyterlab

**Terminal Applications:**
- Wezterm, Ghostty (terminals)
- Zellij, tmux (multiplexers)
- ripgrep, fd, fzf, bat, eza (modern CLI tools)
- yazi, xplr, ranger, nnn (file managers)

**GUI Applications:**
- IDEs: VS Code, Zed
- API Tools: Insomnia, Bruno
- Productivity: Raycast, Logseq
- AI Tools: Ollama, Jan, Witsy
- Window Management: Aerospace, Lunar
- And many more (see homebrew.sh for full list)

**System Utilities:**
- Azure CLI, OpenTofu, Ansible
- Docker Desktop
- Bitwarden CLI, LastPass CLI
- mas (Mac App Store CLI)

---

## 🔧 Configuration Structure

### Chezmoi Directory Layout
```
chezmoi/
├── README.md                   # Comprehensive documentation
├── QUICKSTART.md              # Quick reference guide
├── MIGRATION.md               # This file
├── .chezmoiignore            # Files to ignore
├── dot_zshrc                 # ~/.zshrc
├── dot_zshenv                # ~/.zshenv
├── dot_config/               # ~/.config/
│   ├── starship.toml
│   ├── atuin/
│   │   ├── config.toml
│   │   └── themes/
│   │       ├── ayu.toml
│   │       └── tokyo-night.toml
│   ├── ghostty/
│   ├── zellij/
│   │   ├── config.kdl
│   │   ├── layouts/
│   │   └── themes/
│   ├── nvim/
│   └── xplr/
└── scripts/
    ├── bootstrap.sh          # Full setup script
    └── install-essentials.sh # Minimal CLI tools install
```

---

## 🚫 Not Migrated (Nix-Specific)

These items are specific to Nix/home-manager and don't apply to the chezmoi setup:

### Nix Module System
- `default.nix` files
- `programs.*` options (e.g., `programs.starship.enable`)
- `xdg.configFile` attribute sets
- Nix package derivations

### System-Level Configurations
- `environment.systemPackages`
- Darwin/NixOS specific settings
- System services (moved to native macOS LaunchAgents if needed)

### Build-Time Features
- Nix flakes
- Package overlays
- Custom package builds

---

## 📝 Usage Differences

### Adding a New Config File

**Before (home-manager):**
```nix
# In some-package/default.nix
xdg.configFile.myapp = {
  target = "myapp/config.toml";
  source = ./config.toml;
};
```

**After (chezmoi):**
```bash
# Just add the file directly
chezmoi add ~/.config/myapp/config.toml

# Or manually create in source directory
cp ~/.config/myapp/config.toml ~/git/nixos-config/chezmoi/dot_config/myapp/
```

### Applying Changes

**Before (home-manager):**
```bash
swork  # Alias for: nix run nix-darwin -- switch --flake .#work
```

**After (chezmoi):**
```bash
chezmoi apply -v
```

### Package Installation

**Before (home-manager):**
```nix
# Edit home.packages in packages.nix
# Run: swork
```

**After (chezmoi):**
```bash
# Edit: ~/git/nixos-config/home/work/homebrew.sh
# Run: ./homebrew.sh
```

---

## 🎯 Benefits of Chezmoi Migration

1. **No admin required** - Works on managed/locked-down computers
2. **Simpler mental model** - Direct file mapping, no Nix language
3. **Faster application** - No building, just copying files
4. **Better portability** - Works on any UNIX-like system
5. **Git-friendly** - Actual config files in repo, easy to review diffs
6. **Template support** - Can still use templating when needed

---

## 🚀 Next Steps

1. **Run the installer:**
   ```bash
   cd ~/git/nixos-config/chezmoi
   ./scripts/install.sh
   ```
   
   **Or test manually:**
   ```bash
   cd ~/git/nixos-config/chezmoi
   chezmoi init --source=$PWD
   chezmoi diff  # See what would change
   ```

2. **Backup current configs:**
   ```bash
   mkdir ~/dotfiles-backup
   cp ~/.zshrc ~/.zshenv ~/dotfiles-backup/
   cp -r ~/.config ~/dotfiles-backup/
   ```

3. **Apply the new configs:**
   ```bash
   chezmoi apply -v
   ```

4. **Install packages:**
   ```bash
   ./scripts/install-essentials.sh  # Essential CLI tools
   # or
   ../home/work/homebrew.sh          # Full development environment
   ```

5. **Restart shell:**
   ```bash
   exec zsh
   ```

6. **Verify everything works:**
   - Check prompt: Should see Starship Tokyo Night theme
   - Try aliases: `ll`, `ga`, `y`, etc.
   - Test tools: `starship --version`, `atuin --version`

---

## 📚 Documentation

- **README.md** - Comprehensive guide to the chezmoi setup
- **QUICKSTART.md** - Quick reference for common tasks
- **MIGRATION.md** - This file

## 🆘 Troubleshooting

See [README.md](README.md) for detailed troubleshooting steps.

Quick fixes:
```bash
# Reload shell
exec zsh

# Re-initialize chezmoi
chezmoi init --source=$HOME/git/nixos-config/chezmoi

# Force apply a specific file
chezmoi apply --force ~/.zshrc

# Check what's managed
chezmoi managed
```
