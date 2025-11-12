"""Dependency injection container."""
from typing import Optional
from src.config import Config
from src.infrastructure.audio_service import PactlClient, AudioSystemClient
from src.application.list_sources_use_case import ListSourcesUseCase
from src.application.switch_source_use_case import SwitchSourceUseCase
from src.presentation.ulauncher_adapter import MicSwitcherPresenter


class Container:
    """Dependency injection container."""
    
    def __init__(self, config: Optional[Config] = None):
        self._config = config or Config()
        self._audio_client: Optional[AudioSystemClient] = None
        self._list_use_case: Optional[ListSourcesUseCase] = None
        self._switch_use_case: Optional[SwitchSourceUseCase] = None
        self._presenter: Optional[MicSwitcherPresenter] = None
    
    def audio_client(self) -> AudioSystemClient:
        """Get audio system client."""
        if self._audio_client is None:
            self._audio_client = PactlClient(
                timeout=self._config.pactl_timeout,
                set_source_timeout=self._config.set_source_timeout,
                move_stream_timeout=self._config.move_stream_timeout
            )
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
    
    def presenter(self) -> MicSwitcherPresenter:
        """Get presenter."""
        if self._presenter is None:
            self._presenter = MicSwitcherPresenter(
                self.list_sources_use_case(),
                self.switch_source_use_case(),
                max_sources=self._config.max_sources_display,
                notification_expire_time=self._config.notification_expire_time
            )
        return self._presenter
