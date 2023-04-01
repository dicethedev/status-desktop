import typing

import configs
from src.scripts.tools.squish_api import remote_system
from src.scripts.utils import local_system

_SERVER_DIR = configs.squish.INSTALL_DIR / 'bin' / 'squishserver'
_CONFIG_FILE = configs.path.ROOT / 'squish_server.ini'
_PROCESS_NAME = '_squishserver'


def start():
    local_system.execute([_SERVER_DIR, '--configfile', _CONFIG_FILE, '--verbose', '&'])
    local_system.wait_for_started(_PROCESS_NAME, 3)


def stop():
    local_system.kill_process_by_name(_PROCESS_NAME)


def prepare_config():
    if _CONFIG_FILE.exists():
        _CONFIG_FILE.unlink()
    set_cursor_animation(configs.squish.CURSOR_ANIMATION)


# https://doc-snapshots.qt.io/squish/cli-squishserver.html
def configuring(action: str, options: typing.Union[int, str]):
    command = [str(_SERVER_DIR), '--configfile', str(_CONFIG_FILE), '--config', action, options]
    remote_system.execute(command)


def set_cursor_animation(value: int = configs.squish.CURSOR_ANIMATION):
    configuring('setCursorAnimation', value)
