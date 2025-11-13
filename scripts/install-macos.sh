#!/usr/bin/env bash
# macOS (Raycast) installation script

set -e

RAYCAST_EXT_DIR="$HOME/Library/Application Support/com.raycast.macos/extensions"
RAYCAST_TARGET="$RAYCAST_EXT_DIR/select-mic"

echo "Installing for macOS (Raycast)..."

# Check for Homebrew
if ! command -v brew >/dev/null 2>&1; then
    echo "Error: Homebrew not found. Install from https://brew.sh"
    exit 1
fi

# Install switchaudio-osx
if ! brew list switchaudio-osx >/dev/null 2>&1; then
    echo "Installing switchaudio-osx via Homebrew..."
    brew install switchaudio-osx
else
    echo "✓ switchaudio-osx already installed"
fi

# Install Python dependencies
echo "Installing Python dependencies..."
pip3 install -r requirements.txt >/dev/null 2>&1 || echo "Warning: Failed to install Python dependencies"

# Build extension
echo "Building Raycast extension..."
cd macos/raycast
npm install --silent
npm run build
cd ../..

# Create installation directory
mkdir -p "$RAYCAST_EXT_DIR"

# Remove old installation if exists
if [ -d "$RAYCAST_TARGET" ] || [ -L "$RAYCAST_TARGET" ]; then
    rm -rf "$RAYCAST_TARGET"
fi

# Copy extension files
echo "Installing extension to Raycast..."
rsync -a --exclude='node_modules' --exclude='.git' macos/raycast/ "$RAYCAST_TARGET/"

# Copy required Python source
mkdir -p "$RAYCAST_TARGET/lib"
rsync -a src/ "$RAYCAST_TARGET/lib/src/"
rsync -a macos/cli/src/ "$RAYCAST_TARGET/lib/macos/cli/src/"

# Copy CLI wrapper template
cp macos/raycast/raycast_cli.py.template "$RAYCAST_TARGET/raycast_cli.py"
chmod +x "$RAYCAST_TARGET/raycast_cli.py"

echo ""
echo "✓ Extension installed to: $RAYCAST_TARGET"
echo ""
echo "Opening Raycast Extensions..."
open -a Raycast raycast://extensions 2>/dev/null || open -a Raycast

echo ""
echo "Final step: In Raycast, click 'Import Extension' and select:"
echo "  $RAYCAST_TARGET"
echo ""
