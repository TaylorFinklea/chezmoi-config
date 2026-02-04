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

info "Chezmoi source directory: $CHEZMOI_SOURCE_DIR"

# Step 4: Initialize chezmoi with this directory as source
if [ -d "$HOME/.local/share/chezmoi" ]; then
    warn "Removing existing chezmoi directory..."
    rm -rf "$HOME/.local/share/chezmoi"
fi

info "Creating symlink to source directory..."
mkdir -p "$HOME/.local/share"
ln -sf "$CHEZMOI_SOURCE_DIR" "$HOME/.local/share/chezmoi"
success "Chezmoi initialized with source: $CHEZMOI_SOURCE_DIR"

# Step 5: Show what would change
info "Checking what would change..."
chezmoi diff

# Step 6: Ask for confirmation
echo ""
read -p "Apply these changes? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    info "Applying dotfiles..."
    chezmoi apply -v
    success "Dotfiles applied!"
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
