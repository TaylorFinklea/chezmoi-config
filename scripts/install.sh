#!/usr/bin/env bash

# Bootstrap script for setting up dotfiles with chezmoi
# This script installs chezmoi and applies the dotfile configuration

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    error "This script is designed for macOS. Exiting."
    exit 1
fi

info "Starting dotfiles bootstrap process..."

# Step 1: Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    info "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    
    success "Homebrew installed"
else
    success "Homebrew already installed"
fi

# Step 2: Install chezmoi if not present
if ! command -v chezmoi &> /dev/null; then
    info "Installing chezmoi..."
    brew install chezmoi
    success "Chezmoi installed"
else
    success "Chezmoi already installed"
fi

# Step 3: Determine the source directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHEZMOI_SOURCE_DIR="$(dirname "$SCRIPT_DIR")"
CHEZMOI_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/chezmoi"
CHEZMOI_CONFIG_FILE="$CHEZMOI_CONFIG_DIR/chezmoi.toml"
AI_PROFILE="${CHEZMOI_AI_PROFILE:-}"

prompt_ai_profile() {
    local default_profile="$1"
    local reply=""
    while true; do
        echo ""
        echo "Choose the AI config profile for this machine:"
        echo "  1) work"
        echo "  2) personal"
        if [ -n "$default_profile" ]; then
            read -p "Choose [1-2] (default: $default_profile): " -r reply
        else
            read -p "Choose [1-2]: " -r reply
        fi

        if [ -z "$reply" ] && [ -n "$default_profile" ]; then
            AI_PROFILE="$default_profile"
            return 0
        fi

        case "$reply" in
            1|work)
                AI_PROFILE="work"
                return 0
                ;;
            2|personal)
                AI_PROFILE="personal"
                return 0
                ;;
            *)
                warn "Enter 1/work or 2/personal."
                ;;
        esac
    done
}

write_bootstrap_config() {
    mkdir -p "$CHEZMOI_CONFIG_DIR"
    cat > "$CHEZMOI_CONFIG_FILE" <<EOF
sourceDir = "$1"

[update]
    apply = true
    recurseSubmodules = true

[data]
    ai_profile = "$2"
EOF
}

info "Chezmoi source directory: $CHEZMOI_SOURCE_DIR"

if [ -z "$AI_PROFILE" ] && [ -f "$CHEZMOI_CONFIG_FILE" ]; then
    AI_PROFILE="$(awk -F'"' '/ai_profile/ { print $2; exit }' "$CHEZMOI_CONFIG_FILE" || true)"
fi

if [[ "$AI_PROFILE" != "work" && "$AI_PROFILE" != "personal" ]]; then
    prompt_ai_profile ""
else
    prompt_ai_profile "$AI_PROFILE"
fi

info "Using AI config profile: $AI_PROFILE"

# Step 4: Initialize chezmoi with this directory as source
info "Initializing chezmoi with local source..."

CURRENT_SOURCE=""
if command -v chezmoi &> /dev/null; then
    CURRENT_SOURCE="$(chezmoi source-path 2>/dev/null || true)"
fi

EFFECTIVE_SOURCE="$CHEZMOI_SOURCE_DIR"

if [ -n "$CURRENT_SOURCE" ] && [ ! -d "$CURRENT_SOURCE" ]; then
    warn "Chezmoi source path reported as $CURRENT_SOURCE but it doesn't exist; treating as uninitialized"
    CURRENT_SOURCE=""
fi

if [ -n "$CURRENT_SOURCE" ]; then
    if [ "$CURRENT_SOURCE" = "$CHEZMOI_SOURCE_DIR" ]; then
        write_bootstrap_config "$CHEZMOI_SOURCE_DIR" "$AI_PROFILE"
        success "Chezmoi already initialized with this source"
        EFFECTIVE_SOURCE="$CHEZMOI_SOURCE_DIR"
    else
        warn "Chezmoi already initialized with: $CURRENT_SOURCE"
        read -p "Reinitialize to use $CHEZMOI_SOURCE_DIR? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            write_bootstrap_config "$CHEZMOI_SOURCE_DIR" "$AI_PROFILE"
            chezmoi init --source="$CHEZMOI_SOURCE_DIR" --force
            success "Chezmoi reinitialized with source: $CHEZMOI_SOURCE_DIR"
            EFFECTIVE_SOURCE="$CHEZMOI_SOURCE_DIR"
        else
            warn "Keeping existing chezmoi source"
            EFFECTIVE_SOURCE="$CURRENT_SOURCE"
        fi
    fi
else
    write_bootstrap_config "$CHEZMOI_SOURCE_DIR" "$AI_PROFILE"
    chezmoi init --source="$CHEZMOI_SOURCE_DIR"
    success "Chezmoi initialized with source: $CHEZMOI_SOURCE_DIR"
    EFFECTIVE_SOURCE="$CHEZMOI_SOURCE_DIR"
fi

# Step 5: Show what would change
info "Checking what would change..."
chezmoi -S "$EFFECTIVE_SOURCE" diff

# Step 6: Ask for confirmation
echo ""
read -p "Apply these changes? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    info "Applying dotfiles..."
    chezmoi -S "$EFFECTIVE_SOURCE" apply -v
    success "Dotfiles applied!"

    # Step 6b: Bootstrap lazy.nvim if Neovim config is present
    if [ -f "$HOME/.config/nvim/init.lua" ]; then
        if command -v git &> /dev/null; then
            LAZY_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy/lazy.nvim"
            if [ ! -d "$LAZY_PATH" ]; then
                info "Bootstrapping lazy.nvim..."
                mkdir -p "$(dirname "$LAZY_PATH")"
                if git clone --filter=blob:none --branch=stable https://github.com/folke/lazy.nvim.git "$LAZY_PATH"; then
                    success "lazy.nvim installed"
                else
                    warn "Failed to clone lazy.nvim. You can retry later with:"
                    warn "  git clone --filter=blob:none --branch=stable https://github.com/folke/lazy.nvim.git $LAZY_PATH"
                fi
            else
                success "lazy.nvim already installed"
            fi
        else
            warn "git not found; skipping lazy.nvim bootstrap"
        fi
    else
        warn "Neovim config not found; skipping lazy.nvim bootstrap"
    fi
else
    warn "Dotfile application cancelled. You can apply manually with: chezmoi apply -v"
fi

# Step 7: Install essential packages
echo ""
read -p "Install essential CLI tools via Homebrew? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    info "Installing essential CLI tools..."
    
    # Core utilities
    ESSENTIAL_TOOLS=(
        "starship"       # Prompt
        "atuin"          # Shell history
        "zoxide"         # Smart cd
        "fzf"            # Fuzzy finder
        "ripgrep"        # Better grep
        "fd"             # Better find
        "bat"            # Better cat
        "eza"            # Better ls
        "git"            # Version control
        "gh"             # GitHub CLI
        "jq"             # JSON processor
        "yazi"           # File manager
        "zellij"         # Terminal multiplexer
        "neovim"         # Editor
    )
    
    for tool in "${ESSENTIAL_TOOLS[@]}"; do
        if ! brew list "$tool" &> /dev/null; then
            info "Installing $tool..."
            brew install "$tool"
        else
            success "$tool already installed"
        fi
    done
    
    # Zsh plugins
    info "Installing zsh plugins..."
    brew install zsh-autosuggestions zsh-syntax-highlighting
    
    success "Essential tools installed!"
else
    warn "Skipped package installation"
fi

# Step 8: Install development tools
echo ""
# Auto-detect system type based on hostname
HOSTNAME=$(hostname -s)
COMPUTER_NAME=$(scutil --get ComputerName 2>/dev/null || echo "$HOSTNAME")

# Check if this is a work computer (contains "work", "it-", "corp", etc.)
if [[ "$COMPUTER_NAME" =~ (work|it-|corp|company) ]] || [[ "$HOSTNAME" =~ (work|it-|corp|company) ]]; then
    DETECTED_TYPE="work"
    info "Detected WORK computer: $COMPUTER_NAME"
else
    DETECTED_TYPE="personal"
    info "Detected PERSONAL computer: $COMPUTER_NAME"
fi

echo ""
echo "Install Homebrew packages?"
echo "  1) Yes, use detected configuration ($DETECTED_TYPE)"
echo "  2) Work (excludes: Zed, Insomnia, Bruno, Ollama, Voiceink)"
echo "  3) Personal (full suite)"
echo "  4) Skip package installation"
read -p "Choose [1-4] (default: 1): " -n 1 -r
echo

# Default to option 1 if user just presses enter
REPLY=${REPLY:-1}

case $REPLY in
    1)
        if [ "$DETECTED_TYPE" = "work" ]; then
            info "Installing work configuration..."
            bash "$SCRIPT_DIR/install-homebrew-work.sh"
        else
            info "Installing personal configuration..."
            bash "$SCRIPT_DIR/install-homebrew-personal.sh"
        fi
        ;;
    2)
        info "Installing work configuration..."
        bash "$SCRIPT_DIR/install-homebrew-work.sh"
        ;;
    3)
        info "Installing personal configuration..."
        bash "$SCRIPT_DIR/install-homebrew-personal.sh"
        ;;
    4)
        warn "Skipped package installation"
        ;;
    *)
        warn "Invalid choice. Skipping package installation."
        info "You can run scripts manually later:"
        info "  Work: ./scripts/install-homebrew-work.sh"
        info "  Personal: ./scripts/install-homebrew-personal.sh"
        ;;
esac

# Final messages
echo ""
success "Bootstrap complete!"
echo ""
info "Next steps:"
echo "  1. Restart your shell or run: exec zsh"
echo "  2. Configure atuin: atuin register (if using sync)"
echo "  3. Check chezmoi status: chezmoi status"
echo "  4. Edit configs in: $CHEZMOI_SOURCE_DIR"
echo "  5. Apply changes: chezmoi apply -v"
echo ""
info "For more information, see: $CHEZMOI_SOURCE_DIR/README.md"
