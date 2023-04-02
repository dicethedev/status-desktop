import logging

import pytest

from scripts.tools.squish_api import squish_server
from scripts.utils import fabricates

_logger = logging.getLogger(__name__)


@pytest.fixture(scope='session')
def server():
    _logger.info(fabricates.generate_log_title('Setup session: Squish server'))
    squish_server.stop()
    attempt = 3
    while True:
        try:
            squish_server.start()
            break
        except AssertionError as err:
            attempt -= 1
            if not attempt:
                pytest.exit(err)
    squish_server.prepare_config()
    yield
    squish_server.stop()
