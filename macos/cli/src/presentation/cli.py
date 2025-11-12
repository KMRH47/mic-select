"""Command-line interface for Raycast integration."""
import json
import sys
import logging
from typing import Dict, Any, TYPE_CHECKING

if TYPE_CHECKING:
    from macos.cli.src.dependency_injection.container import Container
else:
    try:
        from macos.cli.src.dependency_injection.container import Container
    except ImportError:
        from src.dependency_injection.container import Container

logger = logging.getLogger(__name__)


def output_json(data: Dict[str, Any], exit_code: int = 0) -> None:
    """
    Output JSON data and exit.
    
    Args:
        data: Dictionary to serialize as JSON
        exit_code: Exit code to use
    """
    try:
        json.dump(data, sys.stdout, indent=2)
        sys.stdout.write("\n")
        sys.exit(exit_code)
    except (TypeError, ValueError) as e:
        output_error(f"Failed to serialize JSON: {e}", 1)


def output_error(message: str, exit_code: int = 1) -> None:
    """
    Output error as JSON and exit.
    
    Args:
        message: Error message
        exit_code: Exit code to use
    """
    output_json({"error": message}, exit_code)


def list_command(container: Container, query: str = "", limit: int = 10) -> None:
    """
    Execute list command.
    
    Args:
        container: Dependency injection container
        query: Optional search query to filter sources
        limit: Maximum number of sources to return
    """
    try:
        use_case = container.list_sources_use_case()
        sources = use_case.execute(query=query, limit=limit)
        
        sources_data = [
            {"name": source.name, "index": source.index}
            for source in sources.sources
        ]
        
        output_json({"sources": sources_data})
    except ValueError as e:
        output_error(str(e), 1)
    except Exception as e:
        logger.error(f"Error in list command: {e}", exc_info=True)
        output_error(f"Failed to list sources: {e}", 1)


def switch_command(container: Container, name: str) -> None:
    """
    Execute switch command.
    
    Args:
        container: Dependency injection container
        name: Name of the source to switch to
    """
    try:
        if not name or not name.strip():
            output_error("Source name cannot be empty", 1)
            return
        
        use_case = container.switch_source_use_case()
        use_case.execute(name.strip())
        
        output_json({
            "success": True,
            "message": f"Switched to audio source: {name.strip()}"
        })
    except ValueError as e:
        output_error(str(e), 1)
    except RuntimeError as e:
        output_error(str(e), 1)
    except Exception as e:
        logger.error(f"Error in switch command: {e}", exc_info=True)
        output_error(f"Failed to switch source: {e}", 1)
