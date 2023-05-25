import logging
import time
from datetime import datetime

import pytest

import configs
import constants
import driver
from constants import UserAccount
from gui.components.before_started_popup import BeforeStartedPopUp
from gui.components.splash_screen import SplashScreen
from gui.main_window import MainWindow
from gui.screens.onboarding import AllowNotificationsView

_logger = logging.getLogger(__name__)


@pytest.fixture
def aut() -> driver.aut.ExecutableAut:
    _aut = driver.aut.ExecutableAut(configs.path.AUT)
    if not configs.path.AUT.exists():
        pytest.exit(f"Application not found: {configs.path.AUT}")
    yield _aut
    _aut.detach()


@pytest.fixture
def app_data() -> driver.system_path.SystemPath:
    yield configs.path.STATUS_DATA / f'data_{datetime.now():%H%M%S_%f}'


@pytest.fixture
def main_window(request, aut: driver.aut.ExecutableAut, app_data) -> MainWindow:
    if hasattr(request, 'param'):
        user_data = request.param
        user_data.copy_to(app_data / 'data')

    aut.start(f'--datadir={app_data}')
    yield MainWindow().wait_until_appears().prepare()


@pytest.fixture
def main_screen(request, main_window: MainWindow) -> MainWindow:
    if hasattr(request, 'param'):
        user_account = request.param
        assert isinstance(user_account, UserAccount)
    else:
        user_account = constants.user.user_account_1

    AllowNotificationsView().wait_until_appears().allow()
    BeforeStartedPopUp().get_started()
    main_window.welcome_screen.sign_up(user_account)
    SplashScreen().wait_until_appears().wait_until_hidden(driver.config.APP_LOAD_TIMEOUT_MSEC)
    yield main_window


@pytest.fixture(scope='session')
def terminate_old_processes():
    driver.local_system.kill_process_by_name(configs.path.AUT.name)
