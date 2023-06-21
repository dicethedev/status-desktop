import os

print(os.environ.get('LD_LIBRARY_PATH'))
print(os.environ.get('PYTHONPATH'))
print(os.environ.get('SQUISH_DIR'))

os.environ["LD_LIBRARY_PATH"] = "/home/squisher/Workspace/Qt/5.15.2/gcc_64/lib:/home/squisher/Workspace/squish/lib:/home/squisher/Workspace/squish/lib/python:/home/squisher/Workspace/squish/python3/lib:/opt/Qt/5.15.2/gcc_64/lib:/home/squisher/Workspace/status-desktop/vendor/DOtherSide/build/qzxing:/home/squisher/Workspace/status-desktop/vendor/status-go/build/bin:/home/squisher/Workspace/status-desktop/vendor/status-keycard-go/build/libkeycard"
os.environ["PYTHONPATH"] = "/home/squisher/Workspace/squish/lib:/home/squisher/Workspace/squish/lib/python"
os.environ["SQUISH_DIR"] = "/home/squisher/Workspace/squish"

import logging

import pytest

import configs
import driver
from tests.fixtures.path import generate_test_info

_logger = logging.getLogger(__name__)

pytest_plugins = [
    'tests.fixtures.aut',
    'tests.fixtures.path',
    'tests.fixtures.squish',
    'tests.fixtures.testrail',
    'tests.fixtures.vms',
]


@pytest.fixture(scope='session', autouse=True)
def setup_session_scope(
        init_testrail_api,
        terminate_old_processes,
        run_dir,  # adds test directories, clears temp data, and fills configs
        vms
):
    _logger.info('Setup session: Done')


@pytest.fixture(scope='function', autouse=True)
def setup_test_scope(
        check_result
):
    _logger.info('Setup test: Done')


@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call):
    outcome = yield
    rep = outcome.get_result()
    setattr(item, 'rep_' + rep.when, rep)


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
        driver.local_system.kill_process_by_name(configs.path.AUT.name)

        # TODO: Save application logs
    except Exception as ex:
        _logger.info(f'Failed test was not handle: {ex}')
