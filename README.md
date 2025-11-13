# Mic Switcher

Quick microphone switcher.

Works on:
- macOS (Raycast)
- Linux (Ulauncher)

## Install

```bash
make install
```

## Use

Type `mic` in Raycast/Ulauncher to list and switch microphones.

### Virtual Routing (Optional)

For apps that don't respect system defaults (Teams, Zoom):

1. Install BlackHole: `brew install blackhole-2ch`
2. Start daemon: `./macos/mic-router-daemon`
3. Set apps to use "BlackHole 2ch" as input
4. Switch mics normally - daemon routes to BlackHole

## Uninstall

```bash
make uninstall
```
