"""Platform detection and audio client factory."""
import sys
import logging
from typing import TYPE_CHECKING
from src.config import Config
from src.infrastructure.audio_service import AudioSystemClient

logger = logging.getLogger(__name__)

if TYPE_CHECKING:
    from src.infrastructure.audio_service import PactlClient
    from src.infrastructure.macos_audio_service import MacOSAudioClient


def detect_platform() -> str:
    """
    Detect the current platform.
    
    Returns:
        Platform identifier: "linux", "darwin", or "unknown"
    """
    platform = sys.platform.lower()
    if platform.startswith("linux"):
        return "linux"
    elif platform == "darwin":
        return "darwin"
    else:
        return "unknown"


def get_audio_client(config: Config) -> AudioSystemClient:
    """
    Get platform-specific audio client.
    
    Args:
        config: Configuration object
        
    Returns:
        Platform-specific audio client implementation
        
    Raises:
        RuntimeError: If platform is unsupported or client initialization fails
    """
    platform = detect_platform()
    
    if platform == "linux":
        if sys.platform == "darwin":
            raise RuntimeError("PactlClient cannot be used on macOS")
        
        from src.infrastructure.audio_service import PactlClient
        return PactlClient(
            timeout=config.pactl_timeout,
            set_source_timeout=config.set_source_timeout,
            move_stream_timeout=config.move_stream_timeout
        )
    
    elif platform == "darwin":
        if sys.platform != "darwin":
            raise RuntimeError("MacOSAudioClient can only be used on macOS")
        
        from src.infrastructure.macos_audio_service import MacOSAudioClient
        return MacOSAudioClient(
            timeout=config.pactl_timeout,
            set_source_timeout=config.set_source_timeout
        )
    
    else:
        raise RuntimeError(f"Unsupported platform: {platform}")
