import logging
import re

import pytest

import configs
from src.scripts.utils import fabricates
from src.scripts.utils.path import Path

_logger = logging.getLogger(__name__)


@pytest.fixture(autouse=True)
def clear_user_data():
    _logger.info(fabricates.generate_log_title('Setup function: Clear user data'))
    if configs.path.STATUS_DATA.exists():
        configs.path.STATUS_DATA.rmtree()
    else:
        _logger.info('User data is empty')


@pytest.fixture(autouse=True)
def generate_test_data(request):
    _logger.info(fabricates.generate_log_title('Setup function: Test Run'))
    test_path, test_name, test_params = generate_test_info(request.node)
    configs.path.TEST = configs.path.RUN / test_path / test_name
    node_dir = configs.path.TEST / test_params
    configs.path.TEST_ARTIFACTS = node_dir / 'artifacts'
    configs.path.TEST_VP = configs.path.VP / test_path / test_name
    _logger.info(fabricates.generate_log_title(f'Start test: {test_name}'))
    _logger.info(
        f'\nArtifacts directory:\t{configs.path.TEST_ARTIFACTS.relative_to(configs.path.ROOT)}'
        f'\nVerification points directory:\t{configs.path.TEST_VP.relative_to(configs.path.ROOT)}'
    )


def generate_test_info(node):
    pure_path = Path(node.location[0]).parts[1:]
    test_path = Path(*pure_path).with_suffix('')
    test_name = node.originalname
    test_params = re.sub('[^a-zA-Z0-9\n\-_]', '', node.name.strip(test_name))
    return test_path, test_name, test_params


@pytest.fixture(scope='session')
def run_dir():
    _logger.info(fabricates.generate_log_title('Setup session: Directories'))
    keep_results = 5
    run_name_pattern = 'run_ ????????_??????'
    runs = list(sorted(configs.path.RESULTS.glob(run_name_pattern)))
    if len(runs) > keep_results:
        del_runs = runs[:len(runs) - keep_results]
        for run in del_runs:
            Path(run).rmtree()
            _logger.info(f"Remove old test run directory: {run.relative_to(configs.path.ROOT)}")
    configs.path.RUN.mkdir(parents=True, exist_ok=True)
    _logger.info(f"Created new test run directory: {configs.path.RUN.relative_to(configs.path.ROOT)}")
