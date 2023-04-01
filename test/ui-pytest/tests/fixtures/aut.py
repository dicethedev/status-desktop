import logging

import pytest

import configs
from src.scripts.tools.aut.executable_aut import ExecutableAut

_logger = logging.getLogger(__name__)


@pytest.fixture
def aut() -> ExecutableAut:
    _aut = ExecutableAut(configs.path.AUT)
    if not configs.path.AUT.exists():
        pytest.exit(f"Application not found: {configs.path.AUT}")

    yield _aut
    _aut.detach()
    _aut.close()


@pytest.fixture
def login_window(aut: ExecutableAut):
    aut.start()
    yield
    aut.close()
