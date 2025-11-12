.PHONY: install uninstall test test-unit test-integration test-coverage clean format lint type-check check

EXTENSION_DIR := $(HOME)/.local/share/ulauncher/extensions/mic-switcher.kmrh47
ICON_URL := https://cdn-icons-png.flaticon.com/512/107/107831.png

install:
	@mkdir -p $(EXTENSION_DIR)
	@cp manifest.json main.py $(EXTENSION_DIR)/
	@cp -r src $(EXTENSION_DIR)/
	@[ -f $(EXTENSION_DIR)/icon.png ] || wget -q -O $(EXTENSION_DIR)/icon.png $(ICON_URL) 2>/dev/null || true
	@echo "Installed. Restart Ulauncher: killall ulauncher && ulauncher &"

uninstall:
	@rm -rf $(EXTENSION_DIR)
	@echo "Uninstalled"

test:
	@.venv/bin/pytest

test-unit:
	@.venv/bin/pytest tests/unit -v

test-integration:
	@.venv/bin/pytest tests/integration -v

test-coverage:
	@.venv/bin/pytest --cov=src --cov-report=html --cov-report=term

format:
	@.venv/bin/black src tests main.py
	@.venv/bin/isort src tests main.py

lint:
	@.venv/bin/ruff check src tests main.py

type-check:
	@.venv/bin/mypy src main.py --ignore-missing-imports

check: format lint type-check test
	@echo "All checks passed"

clean:
	@rm -rf .pytest_cache htmlcov .coverage .mypy_cache .ruff_cache
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
