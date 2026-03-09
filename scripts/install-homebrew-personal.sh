#!/bin/bash

# Homebrew Installation Script - PERSONAL CONFIGURATION
# Full suite of tools for personal computer

set -e

echo "🍺 Starting Homebrew installation (PERSONAL configuration)..."

# Ensure Homebrew is installed
if ! command -v brew &>/dev/null; then
  echo "❌ Homebrew is not installed. Please install it first:"
  echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
  exit 1
fi

# Update Homebrew
echo "📦 Updating Homebrew..."
brew update

# Add taps
echo "🔧 Adding taps..."
TAPS=(
  "atlassian/homebrew-acli"
  "sst/tap"
  "knqyf263/pet"
  "FelixKratz/formulae"
  "nikitabobko/tap"
  "steipete/tap"
)

for tap in "${TAPS[@]}"; do
  if ! brew tap | grep -q "^${tap}$"; then
    echo "  Adding tap: $tap"
    brew tap "$tap"
  else
    echo "  ✓ Tap already added: $tap"
  fi
done

# Define casks to install - FULL PERSONAL SUITE
CASKS=(
  # Development & Programming
  "wezterm"
  "ghostty"
  "visual-studio-code"
  "zed"
  "insomnia"
  "bruno"
  "docker-desktop"
  "github"

  # AI & Machine Learning
  "ollama-app"
  "voiceink"
  "witsy"
  "jan"
  "codexbar"
  "opencode-desktop"
  "langflow"
  "block-goose"

  # Productivity & Organization
  "raycast"
  "maccy"
  "espanso"
  "logseq"

  # System Utilities
  "aerospace"
  "lunar"
  "kindavim"
  "wooshy"
  "shortcat"
  "superkey"
  "scrolla"
  "shottr"
  "vmware-fusion"

  # Browsers
  "firefox@developer-edition"

  # Media & Graphics
  "obs"
  "figma"
  "inkscape"

  # Hardware & Electronics
  "via"

  # Security & Network
  "lastpass"
  "qmk-toolbox"

  # Utilities
  "xbar"
  "karabiner-elements"

  # Fonts
  "font-fira-mono-nerd-font"
  "font-dejavu-sans-mono-nerd-font"
  "font-droid-sans-mono-nerd-font"
  "font-fira-code-nerd-font"
  "font-hack-nerd-font"
  "font-roboto-mono-nerd-font"
  "font-terminess-ttf-nerd-font"
  "sf-symbols"
)

# Define brews to install
BREWS=(
  # Development Tools
  "bash-language-server"
  "lua-language-server"
  "pyenv"
  "nvm"
  "pnpm"
  "uv"
  "git"
  "git-lfs"
  "chezmoi"
  "just"
  "tmuxinator"
  "jupyterlab"

  # AI & Machine Learning
  "promptfoo"
  "codex"
  "llm"
  "tmuxai"
  "opencode"
  "claude-code"

  # Build Tools
  "qt@6"
  "autoconf"
  "autoconf-archive"
  "automake"
  "ccache"
  "cmake"
  "pkg-config"

  # System Utilities
  "mas"
  "coreutils"
  "bash"
  "xplr"
  "curl"
  "scrcpy"
  "mosh"
  "aspell"
  "git-crypt"
  "pngpaste"
  "navi"
  "pet"

  # Window Management
  "borders"
  "sketchybar"

  # Security & Password Management
  "lastpass-cli"
  "bitwarden-cli"

  # Cloud & Infrastructure
  "azure-cli"
  "opentofu"
  "ansible"

  # Media Tools
  "ffmpeg"

  # Specific Tools
  "acli"
)

# Install casks
echo "🖥️  Installing casks..."
for cask in "${CASKS[@]}"; do
  if brew list --cask | grep -q "^${cask}$"; then
    echo "  ✓ Already installed: $cask"
  else
    echo "  Installing cask: $cask"
    brew install --cask "$cask" || echo "  ⚠️  Failed to install $cask (might not be available)"
  fi
done

# Install brews
echo "🍺 Installing brews..."
for formula in "${BREWS[@]}"; do
  if brew list | grep -q "^${formula}$"; then
    echo "  ✓ Already installed: $formula"
  else
    echo "  Installing formula: $formula"
    brew install "$formula" || echo "  ⚠️  Failed to install $formula (might not be available)"
  fi
done

# Upgrade existing packages
echo "⬆️  Upgrading existing packages..."
brew upgrade

# Clean up
echo "🧹 Cleaning up..."
brew cleanup

echo "✅ Homebrew sync complete (PERSONAL configuration)!"
echo ""
echo "📋 Summary:"
echo "   Taps: ${#TAPS[@]} configured"
echo "   Casks: ${#CASKS[@]} configured"
echo "   Brews: ${#BREWS[@]} configured"
