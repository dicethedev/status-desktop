import logging

import pytest

import configs
from src.scripts.tools.aut.executable_aut import ExecutableAut
from src.scripts.tools.squish_api import squish_server
from src.scripts.utils import fabricates

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


@pytest.fixture(scope='session')
def terminate_old_processes(aut):
    _logger.info(fabricates.generate_log_title('Setup session: Terminate old processes'))
    close_all_aut()
    squish_server.stop()


def close_all_aut():
    ExecutableAut(configs.path.AUT).close()
