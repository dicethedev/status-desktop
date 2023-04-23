import logging

import pytest

import configs
import driver
from tests.fixtures.path import generate_test_info

_logger = logging.getLogger(__name__)

pytest_plugins = [
    'tests.fixtures.aut',
    'tests.fixtures.path',
]


@pytest.fixture(scope='session', autouse=True)
def setup_session_scope(
        terminate_old_processes,
        server,  # prepares driver server config, starts/stops driver server
        run_dir,  # adds test directories, clears temp data, and fills configs
):
    _logger.info('Setup session: Done')


@pytest.fixture(autouse=True)
def setup_function_scope(
        clear_user_data
):
    _logger.info('Setup function: Done')


def pytest_exception_interact(node):
    """Handles test on fail."""
    try:
        # Create test directories
        test_path, test_name, test_params = generate_test_info(node)
        node_dir = configs.path.RUN / test_path / test_name / test_params
        node_dir.mkdir(parents=True, exist_ok=True)

        # TODO: Grab desktop screenshot

        # Close test application
        driver.context.detach()
        driver.utils.local_system.kill_process_by_name(configs.path.AUT.name)

        # TODO: Save application logs
    except Exception as ex:
        _logger.info(f'Failed test was not handle: {ex}')
