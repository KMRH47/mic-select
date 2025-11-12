.PHONY: install uninstall test test-unit test-integration test-coverage clean format lint type-check check install-raycast build-raycast test-macos

EXTENSION_DIR := $(HOME)/.local/share/ulauncher/extensions/mic-switcher.kmrh47

install:
	@mkdir -p $(EXTENSION_DIR)
	@cp linux/ulauncher/manifest.json main.py $(EXTENSION_DIR)/
	@cp -r src $(EXTENSION_DIR)/
	@cp assets/icon.svg $(EXTENSION_DIR)/icon.png
	@echo "Installed. Restart Ulauncher: killall ulauncher && ulauncher &"

uninstall:
	@rm -rf $(EXTENSION_DIR)
	@echo "Uninstalled"

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
