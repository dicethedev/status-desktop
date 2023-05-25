import pytest

import driver


@pytest.fixture(scope='session')
def server():
    driver.server.stop()
    driver.server.start()
    driver.server.prepare_config()
    yield
    driver.server.stop()