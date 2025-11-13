#!/usr/bin/env bash
# macOS (Raycast) uninstallation script

RAYCAST_TARGET="$HOME/Library/Application Support/com.raycast.macos/extensions/select-mic"

if [ -d "$RAYCAST_TARGET" ] || [ -L "$RAYCAST_TARGET" ]; then
    rm -rf "$RAYCAST_TARGET"
    echo "✓ Raycast extension uninstalled"
else
    echo "Extension not found in Raycast"
fi
