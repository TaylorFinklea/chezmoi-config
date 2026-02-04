# Quick Start Guide

## First-Time Setup (New Machine)

**Note:** Only run `install.sh` on a new machine. For daily updates, use `chezmoi update` (see below).

### 1. Install Homebrew (if not already installed)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Clone the repository
```bash
mkdir -p ~/git
cd ~/git
git clone <your-repo-url> chezmoi-config
# or if already cloned:
cd ~/git/chezmoi-config
```

### 3. Run installation script
```bash
cd ~/git/chezmoi-config
./scripts/install.sh
```

The installation script will:
- Install chezmoi
- Initialize your dotfiles
- Auto-detect work vs personal computer
- Optionally install packages (work or personal configuration)

### 4. Restart your shell
```bash
exec zsh
```

## Daily Usage

### Update dotfiles (the main command you'll use)
```bash
chezmoi update    # Pull git changes and apply
# or use alias:
cup
```

### Other Common Commands
```bash
# See what would change before updating
chezmoi diff      # or: czd

# Edit a file (opens in $EDITOR)
chezmoi edit ~/.zshrc    # or: cze ~/.zshrc

# Apply changes without pulling
chezmoi apply -v         # or: cza

# Check status
chezmoi status          # or: czs

# Add a new file to chezmoi
chezmoi add ~/.config/newapp/config.toml
```

### Installing Packages

#### Essential CLI tools only
```bash
./scripts/install-essentials.sh
```

#### Full development environment
```bash
# For work computer
./scripts/install-homebrew-work.sh

# For personal computer
./scripts/install-homebrew-personal.sh
```

**Note:** When you add/remove apps from these scripts, just re-run the appropriate script. The scripts check what's already installed and only install new packages.

## Customization

### Edit configurations
All configs are in `~/git/chezmoi-config/`
- Shell: `dot_zshrc`, `dot_zshenv`
- Starship: `dot_config/starship.toml`
- Atuin: `dot_config/atuin/config.toml`
- Other apps: `dot_config/<app>/`

### Apply changes
After editing:
```bash
cd ~/git/chezmoi-config
chezmoi apply -v
```

### Sync to other machines
```bash
cd ~/git/chezmoi-config
git add .
git commit -m "Update configs"
git push

# On other machine:
cd ~/git/chezmoi-config
git pull
chezmoi apply -v
```

## Troubleshooting

### Shell not using new config
```bash
exec zsh  # Restart the shell
```

### Chezmoi not finding source
```bash
chezmoi init --source=$HOME/git/chezmoi-config
```

### Reset a specific file
```bash
chezmoi apply --force ~/.zshrc
```

### See what chezmoi manages
```bash
chezmoi managed
```

## File Location Reference

| Description | Chezmoi Path | Actual Path |
|-------------|--------------|-------------|
| Zsh RC | `dot_zshrc` | `~/.zshrc` |
| Zsh Env | `dot_zshenv` | `~/.zshenv` |
| Fish Config | `dot_config/fish/config.fish` | `~/.config/fish/config.fish` |
| Starship | `dot_config/starship.toml` | `~/.config/starship.toml` |
| Atuin | `dot_config/atuin/` | `~/.config/atuin/` |
| Ghostty | `dot_config/ghostty/` | `~/.config/ghostty/` |
| Zellij | `dot_config/zellij/` | `~/.config/zellij/` |
| Neovim | `dot_config/nvim/` | `~/.config/nvim/` |

## Migration from home-manager

The main differences:
1. **No Nix required** - Everything is managed by chezmoi + Homebrew
2. **Manual package installation** - Use `scripts/install-homebrew-*.sh` instead of nix packages
3. **Config files are raw** - No `.nix` wrappers, just the actual config files
4. **Explicit application** - Run `chezmoi apply` to sync changes

## Additional Resources

- [Chezmoi Documentation](https://www.chezmoi.io/)
- [Main README](README.md) - Comprehensive guide
- [Homebrew Script (Work)](scripts/install-homebrew-work.sh) - Work package list
- [Homebrew Script (Personal)](scripts/install-homebrew-personal.sh) - Full package list
