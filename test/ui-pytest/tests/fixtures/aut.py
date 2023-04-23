import logging
import time

import pytest

import configs
import constants
import driver
from constants import UserAccount
from gui.components.before_started_popup import BeforeStartedPopUp
from gui.components.splash_screen import SplashScreen
from gui.main_window import MainWindow

_logger = logging.getLogger(__name__)


def generate_log_title(title: str, title_length: int = 80) -> str:
    space = title_length - 2 - len(title)
    return '\n' + int(space / 2) * '-' + ' ' + title + ' ' + int(space / 2) * '-'


@pytest.fixture(scope='session')
def server():
    _logger.info(generate_log_title('Setup session: Squish server'))
    driver.server.stop()
    driver.server.start()
    driver.server.prepare_config()
    yield
    driver.server.stop()


@pytest.fixture
def aut() -> driver.aut.ExecutableAut:
    _aut = driver.aut.ExecutableAut(configs.path.AUT)
    if not configs.path.AUT.exists():
        pytest.exit(f"Application not found: {configs.path.AUT}")
    yield _aut
    _aut.detach()
    _aut.close()


@pytest.fixture
def main_window(request, aut: driver.aut.ExecutableAut) -> MainWindow:
    if hasattr(request, 'param'):
        user_account = request.param
        assert isinstance(user_account, UserAccount)
    else:
        user_account = constants.user.user_account_1

    aut.start()
    main_window = MainWindow().wait_until_appears().prepare()
    # TODO: move to event handler
    BeforeStartedPopUp().get_started()
    main_window.welcome_screen.sign_up(user_account)
    SplashScreen().wait_until_appears().wait_until_hidden(driver.config.APP_LOAD_TIMEOUT_MSEC)
    yield main_window


@pytest.fixture(scope='session')
def terminate_old_processes():
    _logger.info(generate_log_title('Setup session: Terminate old processes'))
    driver.local_system.kill_process_by_name(configs.path.AUT.name)
