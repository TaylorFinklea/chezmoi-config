#!/bin/bash
# Install VS Code extensions from vscode-extensions.txt

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTENSIONS_FILE="$SCRIPT_DIR/../vscode-extensions.txt"

# Check if VS Code is installed
if [ ! -d "/Applications/Visual Studio Code.app" ]; then
    echo "❌ VS Code not found. Please install it first."
    exit 1
fi

CODE_BIN="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"

# Check if extensions file exists
if [ ! -f "$EXTENSIONS_FILE" ]; then
    echo "❌ Extensions file not found: $EXTENSIONS_FILE"
    exit 1
fi

echo "📦 Installing VS Code extensions..."

while IFS= read -r extension; do
    # Skip empty lines and comments
    [[ -z "$extension" || "$extension" =~ ^# ]] && continue
    
    echo "  Installing: $extension"
    "$CODE_BIN" --install-extension "$extension" --force
done < "$EXTENSIONS_FILE"

echo "✅ All VS Code extensions installed!"
