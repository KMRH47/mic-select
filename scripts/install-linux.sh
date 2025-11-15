#!/usr/bin/env bash
# Linux (Ulauncher) installation script

set -e

EXTENSION_DIR="$HOME/.local/share/ulauncher/extensions/mic-switcher"

echo "Installing for Linux (Ulauncher)..."

# Create extension directory
mkdir -p "$EXTENSION_DIR"

# Copy files
cp linux/ulauncher/manifest.json main.py "$EXTENSION_DIR/"
cp -r src "$EXTENSION_DIR/"
cp assets/icon.svg "$EXTENSION_DIR/icon.png"

echo "✓ Installed successfully!"
echo ""
echo "Restart Ulauncher: killall ulauncher && ulauncher &"
