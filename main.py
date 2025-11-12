"""Main entry point for Ulauncher extension."""
import logging
from src.dependency_injection.container import Container
from src.presentation.ulauncher_adapter import MicSwitcherExtension

# Configure logging
logging.basicConfig(
    level=logging.WARNING,
    format='%(asctime)s [%(levelname)8s] %(name)s: %(message)s'
)


def create_extension() -> MicSwitcherExtension:
    """Create and configure the extension."""
    container = Container()
    presenter = container.presenter()
    return MicSwitcherExtension(presenter)


if __name__ == "__main__":
    extension = create_extension()
    extension.run()
