"""macOS-specific dependency injection container."""
import sys
from pathlib import Path
from typing import Optional

_project_root = Path(__file__).parent.parent.parent.parent.parent
if str(_project_root) not in sys.path:
    sys.path.insert(0, str(_project_root))

from src.config import Config
from src.infrastructure.audio_service import AudioSystemClient
from src.infrastructure.platform import get_audio_client
from src.application.list_sources_use_case import ListSourcesUseCase
from src.application.switch_source_use_case import SwitchSourceUseCase


class Container:
    """macOS-specific dependency injection container."""
    
    def __init__(self, config: Optional[Config] = None):
        self._config = config or Config()
        self._audio_client: Optional[AudioSystemClient] = None
        self._list_use_case: Optional[ListSourcesUseCase] = None
        self._switch_use_case: Optional[SwitchSourceUseCase] = None
    
    def audio_client(self) -> AudioSystemClient:
        """Get audio system client."""
        if self._audio_client is None:
            self._audio_client = get_audio_client(self._config)
        return self._audio_client
    
    def list_sources_use_case(self) -> ListSourcesUseCase:
        """Get list sources use case."""
        if self._list_use_case is None:
            self._list_use_case = ListSourcesUseCase(self.audio_client())
        return self._list_use_case
    
    def switch_source_use_case(self) -> SwitchSourceUseCase:
        """Get switch source use case."""
        if self._switch_use_case is None:
            self._switch_use_case = SwitchSourceUseCase(self.audio_client())
        return self._switch_use_case
