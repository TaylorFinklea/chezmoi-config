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
  "anomalyco/tap"
  "knqyf263/pet"
  "FelixKratz/formulae"
  "nikitabobko/tap"
  "steipete/tap"
  "oven-sh/bun"
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
  "ghostty"
  "alacritty"
  "zed"
  "visual-studio-code"
  "bruno"
  "docker-desktop"
  "github"

  # AI & Machine Learning
  "ollama-app"
  "voiceink"
  "chatgpt"
  "codex-app"
  "codexbar"
  "opencode-desktop"
  "mstystudio"

  # Productivity & Organization
  "raycast"
  "maccy"
  "hiddenbar"
  "espanso"
  "logseq"
  "handy"
  "brainfm"

  # System Utilities
  "aerospace"
  "lunar"
  "tonisives/tap/ovim"

  # "superkey"
  "shottr"

  # Browsers
  # "firefox@developer-edition"
  "google-chrome"

  # Media & Graphics
  "obs"
  "figma"
  "inkscape"

  # Utilities
  "xbar"

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
  "bun"
  "uv"
  "git"
  "git-lfs"
  "gh"
  "fzf"
  "btop"
  "viddy"
  "lazygit"
  "gum"
  "chezmoi"
  "just"
  "tmuxinator"
  "tmuxai"
  "jupyterlab"

  # AI & Machine Learning
  "promptfoo"
  "codex"
  "anomalyco/tap/opencode"
  "claude-code@latest"

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
  "ical-buddy"
  "libqalculate"

  # Window Management
  "borders"

  # Security & Password Management
  "lastpass-cli"
  "bitwarden-cli"

  # Cloud & Infrastructure
  "azure-cli"
  "flyctl"
  "opentofu"
  "ansible"
  "railway"

  # Media Tools
  "ffmpeg"

  # Specific Tools
  "acli"
)

GH_EXTENSIONS=(
  "dlvhdr/gh-dash"
)

# Install casks
echo "🖥️  Installing casks..."
for cask in "${CASKS[@]}"; do
  cask_token="${cask##*/}"
  if brew list --cask | grep -q "^${cask_token}$"; then
    echo "  ✓ Already installed: $cask"
  else
    echo "  Installing cask: $cask"
    brew install --cask "$cask" || echo "  ⚠️  Failed to install $cask (might not be available)"
  fi
done

# Install brews
echo "🍺 Installing brews..."
for formula in "${BREWS[@]}"; do
  formula_token="${formula##*/}"
  if brew list | grep -q "^${formula_token}$"; then
    echo "  ✓ Already installed: $formula"
  else
    echo "  Installing formula: $formula"
    brew install "$formula" || echo "  ⚠️  Failed to install $formula (might not be available)"
  fi
done

# Install GitHub CLI extensions
if command -v gh &>/dev/null; then
  echo "🐙 Installing GitHub CLI extensions..."
  for extension in "${GH_EXTENSIONS[@]}"; do
    if gh extension list 2>/dev/null | awk '{print $1}' | grep -qx "$extension"; then
      echo "  ✓ Already installed: $extension"
    else
      echo "  Installing GitHub CLI extension: $extension"
      gh extension install "$extension" || echo "  ⚠️  Failed to install $extension"
    fi
  done
else
  echo "  ⚠️  Skipping GitHub CLI extensions because gh is not installed"
fi

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
