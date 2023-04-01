import logging

import pytest
import squishtest  # noqa   # First Squish Inicialisation

import configs
from src.scripts.tools.squish_api import context
from src.scripts.utils import fabricates
from src.scripts.utils.path import Path
from tests.fixtures.aut import close_all_aut
from tests.fixtures.path import generate_test_info

_logger = logging.getLogger(__name__)

pytest_plugins = [
    'tests.fixtures.aut',
    'tests.fixtures.path',
    'tests.fixtures.squish',
]


@pytest.fixture(scope='session', autouse=True)
def setup_session_scope(
        server,  # prepares squish server config, starts/stops squish server
        run_dir  # adds test directories, clears temp data, and fills configs
):
    _logger.info(fabricates.generate_log_title('Setup session: Done'))


@pytest.fixture(autouse=True)
def setup_function_scope(
        clear_user_data
):
    _logger.info(fabricates.generate_log_title('Setup function: Done'))


def pytest_exception_interact(node):
    """Handles test on fail."""
    try:
        # Create test directories
        test_path, test_name, test_params = generate_test_info(node)
        node_dir: Path = configs.path.RUN / test_path / test_name / test_params
        node_dir.mkdir(parents=True, exist_ok=True)

        # TODO: Grab desktop screenshot

        # Close test application
        context.detach()
        close_all_aut()

        # TODO: Save application logs
    except Exception as ex:
        _logger.info(f'Failed test was not handle: {ex}')
