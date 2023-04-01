# Squish initialization
import pytest
import squishtest  # noqa

pytest_plugins = [
    'tests.fixtures.squish',
]


@pytest.fixture(scope='session', autouse=True)
def setup_session_scope(
        server,     # prepare squish server config, start/stop squish server
):
    pass
