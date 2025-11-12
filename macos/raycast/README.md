# Select Microphone - Raycast Extension

Raycast extension for switching between audio input sources on macOS.

## Prerequisites

1. **Python 3.8+** - Should be installed by default on macOS
2. **SwitchAudioSource** - Install via Homebrew:
   ```bash
   brew install switchaudio-osx
   ```

## Installation

1. Install Python dependencies (from project root):
   ```bash
   pip install -r requirements.txt
   ```

2. Install Raycast extension dependencies:
   ```bash
   cd raycast
   npm install
   npm run build
   ```

3. Import extension in Raycast:
   - Open Raycast Preferences (`Cmd + ,`)
   - Go to Extensions
   - Click "Import Extension"
   - Select the `raycast` directory

## Usage

### List Microphones Command

1. Open Raycast (`Cmd + Space`)
2. Type "List Microphones"
3. Search for your microphone
4. Press Enter to switch

### Switch Microphone Command

1. Open Raycast (`Cmd + Space`)
2. Type "Switch Microphone"
3. Search and select your microphone
4. Press Enter to switch

## Troubleshooting

### Python Not Found

If you see "Python 3 not found" error:
- Ensure Python 3 is installed: `python3 --version`
- Check that Python 3 is in your PATH
- Common locations: `/usr/bin/python3`, `/usr/local/bin/python3`, `/opt/homebrew/bin/python3`

### SwitchAudioSource Not Found

If you see "SwitchAudioSource not found" error:
- Install via Homebrew: `brew install switchaudio-osx`
- Verify installation: `which SwitchAudioSource`

### Extension Not Working

1. Check that `raycast_cli.py` is executable:
   ```bash
   chmod +x raycast_cli.py
   ```

2. Test CLI directly:
   ```bash
   python3 raycast_cli.py list
   ```

3. Check Raycast extension logs:
   - Open Raycast Preferences
   - Go to Extensions
   - Select "Select Microphone"
   - Check for error messages

## Development

### Building

```bash
npm run build
```

### Development Mode

```bash
npm run dev
```

### Linting

```bash
npm run lint
```

### Fix Linting Issues

```bash
npm run fix-lint
```

## Architecture

The extension communicates with the Python CLI (`raycast_cli.py`) which handles all business logic:

- **Raycast Extension** (TypeScript/React) - UI layer
- **Python CLI** - Command-line interface
- **Use Cases** - Business logic
- **macOS Audio Service** - Platform-specific audio handling

This separation ensures the core logic remains platform-agnostic and testable.
