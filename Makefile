.PHONY: install install-linux install-macos uninstall uninstall-linux uninstall-macos test test-unit test-integration test-coverage clean format lint type-check check install-raycast build-raycast test-macos

UNAME := $(shell uname)
EXTENSION_DIR := $(HOME)/.local/share/ulauncher/extensions/mic-switcher.kmrh47

install:
	@if [ "$(UNAME)" = "Linux" ]; then \
		$(MAKE) install-linux; \
	elif [ "$(UNAME)" = "Darwin" ]; then \
		$(MAKE) install-macos; \
	else \
		echo "Unsupported OS: $(UNAME)"; \
		exit 1; \
	fi

install-linux:
	@echo "Installing for Linux (Ulauncher)..."
	@mkdir -p $(EXTENSION_DIR)
	@cp linux/ulauncher/manifest.json main.py $(EXTENSION_DIR)/
	@cp -r src $(EXTENSION_DIR)/
	@cp assets/icon.svg $(EXTENSION_DIR)/icon.png
	@echo "Installed. Restart Ulauncher: killall ulauncher && ulauncher &"

install-macos:
	@echo "Installing for macOS (Raycast)..."
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "Error: Homebrew not found. Install from https://brew.sh"; \
		exit 1; \
	fi
	@if ! brew list switchaudio-osx >/dev/null 2>&1; then \
		echo "Installing switchaudio-osx via Homebrew..."; \
		brew install switchaudio-osx; \
	else \
		echo "switchaudio-osx already installed"; \
	fi
	@echo "Installing Python dependencies..."
	@pip install -r requirements.txt
	@echo "Installing Raycast extension dependencies..."
	@cd macos/raycast && npm install
	@echo "Building Raycast extension..."
	@cd macos/raycast && npm run build
	@echo "Linking extension to Raycast..."
	@RAYCAST_EXT_DIR="$$HOME/Library/Application Support/com.raycast.macos/extensions"; \
	EXT_SOURCE="$$(cd macos/raycast && pwd)"; \
	mkdir -p "$$RAYCAST_EXT_DIR"; \
	EXT_LINK="$$RAYCAST_EXT_DIR/select-mic"; \
	if [ -L "$$EXT_LINK" ] || [ -d "$$EXT_LINK" ]; then \
		rm -rf "$$EXT_LINK"; \
	fi; \
	ln -sf "$$EXT_SOURCE" "$$EXT_LINK"; \
	echo "Installation complete! Extension is ready in Raycast."; \
	echo "Opening Raycast preferences to activate the extension..."; \
	open -a Raycast 2>/dev/null || true; \
	sleep 1; \
	osascript -e 'tell application "System Events" to tell process "Raycast" to keystroke "," using command down' 2>/dev/null || true

uninstall:
	@if [ "$(UNAME)" = "Linux" ]; then \
		$(MAKE) uninstall-linux; \
	elif [ "$(UNAME)" = "Darwin" ]; then \
		$(MAKE) uninstall-macos; \
	else \
		echo "Unsupported OS: $(UNAME)"; \
		exit 1; \
	fi

uninstall-linux:
	@rm -rf $(EXTENSION_DIR)
	@echo "Uninstalled"

uninstall-macos:
	@RAYCAST_EXT_DIR="$$HOME/Library/Application Support/com.raycast.macos/extensions"; \
	EXT_LINK="$$RAYCAST_EXT_DIR/select-mic"; \
	if [ -L "$$EXT_LINK" ] || [ -d "$$EXT_LINK" ]; then \
		rm -rf "$$EXT_LINK"; \
		echo "Raycast extension uninstalled."; \
	else \
		echo "Extension not found in Raycast."; \
	fi

install-raycast:
	@echo "Installing Raycast extension dependencies..."
	@cd macos/raycast && npm install
	@echo "Building Raycast extension..."
	@cd macos/raycast && npm run build
	@echo "Raycast extension ready. Import the 'macos/raycast' directory in Raycast preferences."

build-raycast:
	@cd macos/raycast && npm run build

test:
	@.venv/bin/pytest

test-unit:
	@.venv/bin/pytest tests/unit -v

test-integration:
	@.venv/bin/pytest tests/integration -v

test-macos:
	@if [ "$$(uname)" = "Darwin" ]; then \
		.venv/bin/pytest tests/unit/test_macos_audio_service.py -v; \
	else \
		echo "Skipping macOS tests (not on macOS)"; \
	fi

test-coverage:
	@.venv/bin/pytest --cov=src --cov-report=html --cov-report=term

format:
	@.venv/bin/black src tests main.py macos/cli/raycast_cli.py
	@.venv/bin/isort src tests main.py macos/cli/raycast_cli.py

lint:
	@.venv/bin/ruff check src tests main.py macos/cli/raycast_cli.py

type-check:
	@.venv/bin/mypy src main.py macos/cli/raycast_cli.py --ignore-missing-imports

check: format lint type-check test
	@echo "All checks passed"

clean:
	@rm -rf .pytest_cache htmlcov .coverage .mypy_cache .ruff_cache
	@rm -rf macos/raycast/node_modules macos/raycast/dist
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
