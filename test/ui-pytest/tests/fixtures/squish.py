import time

import pytest

import driver


@pytest.fixture(scope='function')
def server():
    driver.server.start()
    driver.server.prepare_config()
    yield
    driver.server.stop()
