import logging

import pytest

import configs

_logger = logging.getLogger(__name__)


@pytest.fixture()
def clear_user_data():
    if configs.path.STATUS_DATA.exists():
        configs.path.STATUS_DATA.rmtree()
