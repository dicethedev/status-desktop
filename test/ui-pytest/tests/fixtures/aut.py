import logging

import pytest

import configs
from constants.user import UserAccount
from gui.components.before_started_pop_up import BeforeStartedPopUp
from gui.main_window import MainWindow
from scripts.tools.aut.executable_aut import ExecutableAut
from scripts.tools.squish_api import squish_server
from scripts.utils import fabricates

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
def main_window(request, aut: ExecutableAut) -> MainWindow:
    aut.start()
    main_window = MainWindow().wait_until_appears().prepare()
    # TODO: move to event handler
    BeforeStartedPopUp().get_started()

    if hasattr(request, 'param'):
        user_account = request.param
        assert isinstance(user_account, UserAccount)

        main_window.welcome_screen \
            .get_keys() \
            .generate_new_keys() \
            .set_display_name(user_account.name) \
            .next() \
            .next() \
            .create_password(user_account.password) \
            .confirm_password(user_account.password)

    yield main_window


@pytest.fixture(scope='session')
def terminate_old_processes(aut):
    _logger.info(fabricates.generate_log_title('Setup session: Terminate old processes'))
    close_all_aut()
    squish_server.stop()


def close_all_aut():
    ExecutableAut(configs.path.AUT).detach().close()
