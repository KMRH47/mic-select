# Select Microphone

Quickly switch microphone input sources. Multi-platform support with platform-specific implementations.

## Features

- List available audio input sources
- Switch between microphones with a single command
- Platform-specific implementations:
  - **Linux**: Uses PulseAudio/PipeWire (`pactl`) via Ulauncher extension
  - **macOS**: Uses `SwitchAudioSource` CLI tool via Raycast extension

## Project Structure

```
select-mic/
├── linux/ulauncher/     # Linux Ulauncher extension (working, isolated)
├── macos/
│   ├── cli/            # macOS Python CLI
│   └── raycast/        # macOS Raycast extension
├── src/                 # Shared core (domain, application, Linux infrastructure)
└── tests/               # Shared tests
```

## Installation

### Linux (Ulauncher)

See [linux/README.md](linux/README.md) for details.

```bash
chmod +x install.sh
./install.sh
```

Or:
```bash
make install
make reload
```

### macOS (Raycast)

See [macos/README.md](macos/README.md) for details.

1. Install Python dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Install `SwitchAudioSource` (if not already installed):
   ```bash
   brew install switchaudio-osx
   ```

3. Install Raycast extension:
   ```bash
   cd macos/raycast
   npm install
   npm run build
   ```

4. Import the extension in Raycast:
   - Open Raycast Preferences
   - Go to Extensions
   - Click "Import Extension"
   - Select the `macos/raycast` directory

## Usage

### Linux (Ulauncher)

1. Open Ulauncher (`Ctrl + Space`)
2. Type `mic `
3. Select microphone and press Enter

### macOS (Raycast)

1. Open Raycast (`Cmd + Space`)
2. Type "List Microphones" or "Switch Microphone"
3. Search and select your microphone
4. Press Enter to switch

### CLI (macOS)

The macOS CLI can be used directly:

```bash
cd macos/cli

# List all microphones
python3 raycast_cli.py list

# List with query filter
python3 raycast_cli.py list --query "USB"

# Switch to a microphone
python3 raycast_cli.py switch --name "Built-in Microphone"
```

## Requirements

### Linux
- Ulauncher
- PulseAudio or PipeWire (`pactl`)

### macOS
- Python 3.8+
- Raycast
- `SwitchAudioSource` (install via Homebrew: `brew install switchaudio-osx`)

## Testing

```bash
# Run all tests
make test

# Run unit tests only
make test-unit

# Run integration tests only
make test-integration

# Run with coverage
make test-coverage
```

See `TESTING.md` for details.

## Architecture

The project follows clean architecture principles with platform separation:

- **Shared Core** (`src/`):
  - **Domain**: Core business logic and models (`src/domain/`)
  - **Application**: Use cases (`src/application/`)
  - **Infrastructure**: Linux-specific implementation (`src/infrastructure/audio_service.py`)

- **Platform-Specific**:
  - **Linux** (`linux/ulauncher/`): Ulauncher extension using shared core
  - **macOS** (`macos/cli/`): Python CLI with macOS-specific infrastructure
  - **macOS** (`macos/raycast/`): Raycast TypeScript extension calling the CLI

Each platform maintains its own infrastructure layer while sharing domain and application logic. This ensures:
- Linux code remains isolated and working
- macOS code can evolve independently
- Shared core is tested and stable
- Easy to add new platforms in the future
