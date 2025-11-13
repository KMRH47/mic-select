#!/usr/bin/env bash
set -e

echo "Installing for macOS (Raycast)..."

if ! command -v brew >/dev/null 2>&1; then
    echo "Error: Homebrew not found. Install from https://brew.sh"
    exit 1
fi

if ! brew list switchaudio-osx >/dev/null 2>&1; then
    echo "Installing switchaudio-osx..."
    brew install switchaudio-osx
else
    echo "✓ switchaudio-osx installed"
fi

echo ""
echo "Do you want to install virtual audio routing for stubborn apps (Teams/Zoom)?"
echo "This allows apps that ignore system defaults to follow your mic switches."
read -p "Install BlackHole + audio daemon? (y/n): " -n 1 -r
echo ""

INSTALL_ROUTING=false
if [[ $REPLY =~ ^[Yy]$ ]]; then
    INSTALL_ROUTING=true
    
    if ! brew list blackhole-2ch >/dev/null 2>&1; then
        echo "Installing BlackHole..."
        brew install --cask blackhole-2ch
        echo ""
        echo "⚠️  BlackHole installer will open. Follow prompts to install."
        echo "    May require approval in System Settings → Privacy & Security"
        open /opt/homebrew/Caskroom/blackhole-2ch/*/BlackHole2ch-*.pkg
        echo ""
        read -p "Press Enter after BlackHole is installed..."
    else
        echo "✓ BlackHole already installed"
    fi
    
    if ! brew list sox >/dev/null 2>&1; then
        echo "Installing sox (audio router)..."
        brew install sox
    else
        echo "✓ sox installed"
    fi
fi

echo "Installing Python dependencies..."
pip3 install -r requirements.txt >/dev/null 2>&1 || true

mkdir -p macos/raycast/lib
rsync -a src/ macos/raycast/lib/src/
rsync -a macos/cli/src/ macos/raycast/lib/macos/cli/src/

cp macos/raycast/raycast_cli.py.template macos/raycast/raycast_cli.py
chmod +x macos/raycast/raycast_cli.py
chmod +x macos/mic-router-daemon

echo "Building Raycast extension..."
cd macos/raycast
npm install --silent
npm run build
cd ../..

RAYCAST_EXT_DIR="$HOME/.config/raycast/extensions/select-mic"
if [ -d "$RAYCAST_EXT_DIR" ]; then
    cp macos/raycast/raycast_cli.py "$RAYCAST_EXT_DIR/"
    cp -r macos/raycast/lib "$RAYCAST_EXT_DIR/"
fi

echo "Activating in Raycast..."
cd macos/raycast
npx ray develop > /dev/null 2>&1 &
DEV_PID=$!
cd ../..

sleep 3
kill $DEV_PID 2>/dev/null || true

echo ""
echo "✓ Installed! Type 'mic' in Raycast to use."

if [ "$INSTALL_ROUTING" = true ]; then
    echo ""
    echo "Starting audio routing daemon..."
    nohup ./macos/mic-router-daemon > /tmp/mic-router-daemon.log 2>&1 &
    sleep 1
    
    if pgrep -f "mic-router-daemon" > /dev/null; then
        echo "✓ Daemon started (routing to BlackHole 2ch)"
        echo ""
        echo "To use virtual routing:"
        echo "  1. Set Teams/Zoom mic to 'BlackHole 2ch'"
        echo "  2. Switch mics with Raycast - they'll follow instantly!"
        echo ""
        echo "Daemon log: /tmp/mic-router-daemon.log"
        echo "Stop daemon: pkill -f mic-router-daemon"
    else
        echo "⚠️  Daemon failed to start. Check /tmp/mic-router-daemon.log"
    fi
fi
