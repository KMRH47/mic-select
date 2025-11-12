# Project Structure

This document explains the organization of the select-mic project.

## Overview

The project is organized with platform separation to keep working code isolated while sharing core business logic.

## Directory Structure

```
select-mic/
├── linux/ulauncher/          # Linux Ulauncher extension (isolated, working)
│   ├── main.py               # Entry point (symlinked to root)
│   ├── manifest.json         # Ulauncher manifest (symlinked to root)
│   └── README.md             # Linux-specific documentation
│
├── macos/                    # macOS implementation
│   ├── cli/                  # Python CLI for Raycast
│   │   ├── raycast_cli.py    # CLI entry point
│   │   └── src/              # macOS-specific modules
│   │       ├── dependency_injection/
│   │       │   └── container.py  # macOS-specific container
│   │       ├── infrastructure/
│   │       │   ├── __init__.py
│   │       │   └── platform.py  # Platform detection (imports from shared src/)
│   │       └── presentation/
│   │           └── cli.py     # CLI interface (imports from shared src/)
│   └── raycast/              # Raycast TypeScript extension
│       ├── package.json
│       ├── tsconfig.json
│       └── src/              # TypeScript source
│
├── src/                      # Shared core (used by Linux)
│   ├── domain/               # Domain models (platform-agnostic)
│   ├── application/         # Use cases (platform-agnostic)
│   ├── infrastructure/       # Infrastructure layer
│   │   ├── audio_service.py      # Linux PactlClient
│   │   ├── macos_audio_service.py # macOS client (import-guarded)
│   │   └── platform.py           # Platform detection (optional)
│   ├── dependency_injection/ # DI container (Linux-compatible)
│   ├── presentation/        # Presentation layer
│   │   ├── ulauncher_adapter.py  # Linux Ulauncher adapter
│   │   └── cli.py                 # CLI interface (used by macOS)
│   └── config.py             # Configuration
│
├── tests/                    # Shared tests
│   ├── unit/                 # Unit tests
│   └── integration/          # Integration tests
│
├── main.py -> linux/ulauncher/main.py        # Symlink for Linux install
├── manifest.json -> linux/ulauncher/manifest.json  # Symlink for Linux install
├── README.md                 # Main documentation
└── STRUCTURE.md              # This file
```

## Key Design Decisions

### 1. Platform Separation

- **Linux code** (`linux/ulauncher/`) is completely isolated
- **macOS code** (`macos/`) has its own directory structure
- **Shared core** (`src/`) contains domain and application logic

### 2. Shared vs Platform-Specific

**Shared (in `src/`):**
- Domain models (`src/domain/`)
- Use cases (`src/application/`)
- Configuration (`src/config.py`)
- Linux infrastructure (`src/infrastructure/audio_service.py`)

**Platform-Specific:**
- Linux: `linux/ulauncher/` - Ulauncher adapter
- macOS: `macos/cli/` - CLI implementation with macOS infrastructure
- macOS: `macos/raycast/` - Raycast TypeScript extension

**Conditionally Shared:**
- `src/infrastructure/macos_audio_service.py` - macOS client (import-guarded, won't load on Linux)
- `src/infrastructure/platform.py` - Platform detection (optional, used by macOS)

### 3. Import Strategy

**Linux (Ulauncher):**
- Imports directly from `src/`
- Uses `PactlClient` directly (no platform detection needed)
- Container uses `PactlClient` on Linux

**macOS (CLI):**
- CLI adds project root to Python path
- Imports shared code from `src/` (domain, application, config)
- Uses macOS-specific modules from `macos/cli/src/` (container, CLI interface)
- macOS container uses platform detection from `src/infrastructure/platform.py` to get `MacOSAudioClient`

**Benefits of this approach:**
- Single source of truth for shared code
- No code duplication or sync issues
- macOS-specific code is isolated in `macos/cli/src/`
- Shared core in `src/` can evolve with confidence

### 4. Backward Compatibility

The Linux container (`src/dependency_injection/container.py`) is backward compatible:
- On Linux: Uses `PactlClient` directly (original behavior)
- On macOS: Tries platform detection, falls back to `PactlClient` if it fails
- This ensures Linux code continues to work unchanged

## Adding New Platforms

To add a new platform (e.g., Windows):

1. Create `windows/` directory
2. Create platform-specific audio client in `src/infrastructure/windows_audio_service.py`
3. Update `src/infrastructure/platform.py` to detect Windows and return Windows client
4. Create `windows/your-app/` directory with platform-specific entry point
5. Create platform-specific container in `windows/your-app/src/dependency_injection/` (imports from shared `src/`)
6. Create presentation layer (CLI, GUI, etc.) in `windows/your-app/src/presentation/`
7. Add tests in `tests/unit/test_windows_*.py`

The key is to import shared code from `src/` rather than copying it.

## Testing

Tests are shared and can test platform-specific code:
- Unit tests mock platform detection
- Integration tests can be platform-specific (use pytest markers)
- macOS tests skip on Linux (and vice versa)

## File Locations Reference

| Component | Linux | macOS |
|-----------|-------|-------|
| Domain models | `src/domain/` | `src/domain/` (shared) |
| Use cases | `src/application/` | `src/application/` (shared) |
| Config | `src/config.py` | `src/config.py` (shared) |
| Infrastructure | `src/infrastructure/audio_service.py` (PactlClient) | `src/infrastructure/macos_audio_service.py` (MacOSAudioClient) |
| Platform detection | N/A (uses PactlClient directly) | `src/infrastructure/platform.py` |
| Container | `src/dependency_injection/container.py` | `macos/cli/src/dependency_injection/container.py` |
| Presentation | `src/presentation/ulauncher_adapter.py` | `macos/cli/src/presentation/cli.py` |
| Entry point | `linux/ulauncher/main.py` | `macos/cli/raycast_cli.py` |

## Symlinks

Symlinks are used for Linux installation compatibility:
- `main.py -> linux/ulauncher/main.py`
- `manifest.json -> linux/ulauncher/manifest.json`

This allows the Ulauncher extension to be installed directly from the repo root without changes to the installation script.
