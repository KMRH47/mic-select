# macOS / Raycast Extension

This directory contains the macOS-specific Raycast extension for switching microphones.

## Structure

- `cli/` - Python CLI that Raycast calls to interact with audio system
- `raycast/` - Raycast extension (TypeScript)

## Prerequisites

1. **Python 3.8+** (usually pre-installed on macOS)
2. **SwitchAudioSource** - Install via Homebrew:
   ```bash
   brew install switchaudio-osx
   ```
3. **Raycast** - Download from [raycast.com](https://raycast.com)

## Installation

### 1. Install Python Dependencies

From the project root:

```bash
pip install -r requirements.txt
```

### 2. Install Raycast Extension

1. Open Raycast
2. Go to Extensions → Add Extension → Import Extension
3. Select the `macos/raycast/` directory
4. Or use Raycast CLI:
   ```bash
   cd macos/raycast
   npm install
   npm run build
   ```

### 3. Verify CLI Works

Test the CLI directly:

```bash
cd macos/cli
python3 raycast_cli.py list
python3 raycast_cli.py switch --name "Built-in Microphone"
```

## Usage

1. Open Raycast (`Cmd + Space`)
2. Type "List Microphones" or "Switch Microphone"
3. Select a microphone from the list
4. Press Enter to switch

## Troubleshooting

### SwitchAudioSource not found

If you see an error about SwitchAudioSource not being found:

```bash
brew install switchaudio-osx
```

Verify installation:

```bash
which SwitchAudioSource
```

### Python not found

Raycast needs to find Python 3. The extension checks these paths:
- `/usr/bin/python3`
- `/usr/local/bin/python3`
- `/opt/homebrew/bin/python3`
- `which python3` (fallback)

If Python is installed elsewhere, you may need to create a symlink or update the extension code.

### CLI Script Path Issues

If Raycast can't find the CLI script, check that:
1. The `macos/cli/raycast_cli.py` file exists
2. The path calculation in `macos/raycast/src/utils.ts` is correct
3. The Raycast extension is running from the correct directory

## Development

### Testing the CLI

```bash
cd macos/cli
python3 raycast_cli.py list --query "USB" --limit 5
python3 raycast_cli.py switch --name "Your Microphone Name"
```

### Building Raycast Extension

```bash
cd macos/raycast
npm install
npm run build
npm run dev  # For development with hot reload
```

### Running Tests

From the project root:

```bash
# Run all tests (includes macOS-specific tests)
make test

# Run only macOS tests (requires macOS)
pytest tests/unit/test_macos_audio_service.py -v
```

## Architecture

The macOS implementation follows the same clean architecture as the Linux version:

- **Domain Layer** (`cli/src/domain/`) - Core business logic, platform-agnostic
- **Application Layer** (`cli/src/application/`) - Use cases
- **Infrastructure Layer** (`cli/src/infrastructure/`) - macOS-specific audio client using SwitchAudioSource
- **Presentation Layer** (`cli/src/presentation/`) - CLI interface

The Raycast extension (`raycast/`) is a thin TypeScript wrapper that calls the Python CLI and displays results.
