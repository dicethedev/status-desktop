import logging
import time
import typing
from collections import namedtuple
from datetime import datetime

import pytest

import configs
import constants
from constants import UserAccount
from driver import system_path, local_system, settings, context
from driver.aut import ApplicationLauncher
from gui.components.before_started_popup import BeforeStartedPopUp
from gui.components.splash_screen import SplashScreen
from gui.main_window import MainWindow
from gui.screens.onboarding import AllowNotificationsView, LoginView

_logger = logging.getLogger(__name__)


@pytest.fixture
def aut() -> ApplicationLauncher:
    if not configs.path.AUT.exists():
        pytest.exit(f"Application not found: {configs.path.AUT}")
    _aut = ApplicationLauncher(configs.path.AUT)
    yield _aut
    _aut.detach().stop()


@pytest.fixture
def app_data() -> system_path.SystemPath:
    yield configs.path.STATUS_DATA / f'app_{datetime.now():%H%M%S_%f}'


@pytest.fixture
def user_data(request) -> system_path.SystemPath:
    user_data = configs.path.STATUS_DATA / f'app_{datetime.now():%H%M%S_%f}' / 'data'
    if hasattr(request, 'param'):
        system_path.SystemPath(request.param).copy_to(user_data)
    yield user_data


@pytest.fixture
def user_data_two(request, user_data) -> system_path.SystemPath:
    user_data = configs.path.STATUS_DATA / f'app_{datetime.now():%H%M%S_%f}' / 'data'
    if hasattr(request, 'param'):
        system_path.SystemPath(request.param).copy_to(user_data)
    yield user_data


@pytest.fixture
def main_window(aut: ApplicationLauncher, user_data: system_path.SystemPath) -> MainWindow:
    aut.launch(f'-d={user_data.parent}')
    yield MainWindow().wait_until_appears().prepare()


@pytest.fixture
def user_account(request) -> UserAccount:
    if hasattr(request, 'param'):
        user_account = request.param
        assert isinstance(user_account, UserAccount)
    else:
        user_account = constants.user.user_account
    yield user_account


@pytest.fixture
def main_screen(user_account: UserAccount, main_window: MainWindow) -> MainWindow:
    if LoginView().is_visible:
        main_window.log_in_user(user_account)
    else:
        main_window.sign_up_user(user_account)
    SplashScreen().wait_until_appears().wait_until_hidden(settings.APP_LOAD_TIMEOUT_MSEC)
    yield main_window


@pytest.fixture(scope='session')
def terminate_old_processes():
    local_system.kill_process_by_name(configs.path.AUT.name, verify=False)
