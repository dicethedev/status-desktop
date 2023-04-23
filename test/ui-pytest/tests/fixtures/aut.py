import logging

import pytest

import configs
import constants.user
from constants.user import UserAccount
from gui.components.before_started_popup import BeforeStartedPopUp
from gui.main_window import MainWindow
from scripts.tools.aut.status_aut import StatusAut
from scripts.utils import fabricates, local_system

_logger = logging.getLogger(__name__)


@pytest.fixture
def aut() -> StatusAut:
    _aut = StatusAut(configs.path.AUT)
    if not configs.path.AUT.exists():
        pytest.exit(f"Application not found: {configs.path.AUT}")
    yield _aut
    _aut.detach()
    _aut.close()


@pytest.fixture
def main_window(request, aut: StatusAut) -> MainWindow:
    if hasattr(request, 'param'):
        user_account = request.param
        assert isinstance(user_account, UserAccount)
    else:
        user_account = constants.user.user_account_1

    main_window: MainWindow = aut.start()
    # TODO: move to event handler
    BeforeStartedPopUp().get_started()
    main_window.welcome_screen.sign_up(user_account)
    yield main_window


@pytest.fixture(scope='session')
def terminate_old_processes():
    _logger.info(fabricates.generate_log_title('Setup session: Terminate old processes'))
    local_system.kill_process_by_name(configs.path.AUT.name)
