#!/bin/bash

# Homebrew Installation Script - WORK CONFIGURATION
# Minimal professional tools for work computer

set -e

echo "🍺 Starting Homebrew installation (WORK configuration)..."

# Ensure Homebrew is installed
if ! command -v brew &> /dev/null; then
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
    "FelixKratz/formulae"
    "nikitabobko/tap"
)

for tap in "${TAPS[@]}"; do
    if ! brew tap | grep -q "^${tap}$"; then
        echo "  Adding tap: $tap"
        brew tap "$tap"
    else
        echo "  ✓ Tap already added: $tap"
    fi
done

CASKS=(
    # Development & Programming
    #"wezterm"
    #"ghostty"
    "visual-studio-code"
    #"docker-desktop"

    # Productivity & Organization
    #"logseq"

    # System Utilities
    #"aerospace"
    "lunar"
    #"kindavim"
    #"wooshy"
    #"shortcat"
    #"superkey"
    #"scrolla"
    "shottr"

    # Browsers
    #"firefox@developer-edition"

    # Media & Graphics
    #"obs"
    "figma"

    # Hardware & Electronics
    #"via"

    # Security & Network
    "lastpass"
    #"qmk-toolbox"

    # Utilities
    #"xbar"
    #"karabiner-elements"

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
    "tmuxinator"
    "jupyterlab"

    # AI & Machine Learning
    "promptfoo"
    "llm"
    "tmuxai"

    # Build Tools
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
    "mosh"
    "aspell"
    "git-crypt"
    "pngpaste"
    "navi"

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

echo "✅ Homebrew sync complete (WORK configuration)!"
echo ""
echo "📋 Summary:"
echo "   Taps: ${#TAPS[@]} configured"
echo "   Casks: ${#CASKS[@]} configured"
echo "   Brews: ${#BREWS[@]} configured"
echo ""
echo "💡 Excluded from work: Zed, Insomnia, Bruno, Ollama, Voiceink"
