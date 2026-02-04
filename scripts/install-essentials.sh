#!/usr/bin/env bash

# Quick Install Script for Essential Tools
# This is a minimal version that just installs the core tools needed

set -e

echo "🚀 Installing essential CLI tools..."

# Ensure Homebrew is available
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew not found. Please run install.sh first."
    exit 1
fi

# Essential tools list
TOOLS=(
    "starship"               # Prompt
    "atuin"                  # Shell history
    "zoxide"                 # Smart cd
    "fzf"                    # Fuzzy finder
    "ripgrep"                # Better grep (rg)
    "fd"                     # Better find
    "bat"                    # Better cat
    "eza"                    # Better ls
    "git"                    # Version control
    "gh"                     # GitHub CLI
    "jq"                     # JSON processor
    "yazi"                   # File manager
    "zellij"                 # Terminal multiplexer
    "neovim"                 # Editor
    "tmux"                   # Terminal multiplexer alternative
    "zsh-autosuggestions"    # Zsh plugin
    "zsh-syntax-highlighting" # Zsh plugin
)

echo "📦 Installing ${#TOOLS[@]} essential tools..."
echo ""

for tool in "${TOOLS[@]}"; do
    if brew list "$tool" &> /dev/null 2>&1; then
        echo "  ✓ $tool (already installed)"
    else
        echo "  📥 Installing $tool..."
        brew install "$tool" > /dev/null 2>&1 && echo "  ✓ $tool installed" || echo "  ⚠️  Failed to install $tool"
    fi
done

echo ""
echo "✅ Essential tools installation complete!"
echo ""
echo "💡 Next steps:"
echo "   1. Restart your shell: exec zsh"
echo "   2. Verify installations: starship --version, atuin --version, etc."
echo "   3. Register atuin for sync (optional): atuin register"
