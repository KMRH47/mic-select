# Linux / Ulauncher Extension

This directory contains the Linux-specific Ulauncher extension for switching microphones.

## Installation

The extension can be installed using the standard Ulauncher installation method:

```bash
chmod +x install.sh
./install.sh
```

Or using Make:

```bash
make install
make reload
```

## Requirements

- Ulauncher
- PulseAudio or PipeWire (`pactl` command)

## Usage

1. Open Ulauncher (`Ctrl + Space`)
2. Type `mic `
3. Select microphone and press Enter

## Structure

- `main.py` - Ulauncher extension entry point
- `manifest.json` - Ulauncher extension manifest
- The extension uses shared code from `../src/` (domain, application, infrastructure)

## Testing

Run tests from the project root:

```bash
make test
```

See `../TESTING.md` for details.
