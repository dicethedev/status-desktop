import typing

import configs
from scripts.tools.squish_api import remote_system
from scripts.utils import local_system

_CONFIG_FILE = configs.path.ROOT / 'squish_server.ini'
_PROCESS_NAME = '_squishserver'


def start():
    local_system.execute([configs.squish.SERVER, '--configfile', _CONFIG_FILE, '--verbose', '&'])
    local_system.wait_for_started(_PROCESS_NAME, 3)


def stop():
    local_system.kill_process_by_name(_PROCESS_NAME)


def prepare_config():
    if _CONFIG_FILE.exists():
        _CONFIG_FILE.unlink()
    set_cursor_animation(configs.squish.CURSOR_ANIMATION)
    set_aut_timeout(configs.squish.APP_LOAD_TIMEOUT_SEC)


# https://doc-snapshots.qt.io/squish/cli-squishserver.html
def configuring(action: str, options: typing.Union[int, str, list]):
    command = [configs.squish.SERVER, '--configfile', str(_CONFIG_FILE), '--config', action, options]
    remote_system.execute(command)


def set_cursor_animation(value):
    configuring('setCursorAnimation', value)


def add_executable_aut(aut_id, app_dir):
    configuring('addAUT', [aut_id, app_dir])


def add_attachable_aut(aut_id: str, port: int):
    configuring('addAttachableAUT', [aut_id, f'localhost: {port}'])


def set_aut_timeout(value):
    configuring('setAUTTimeout', value)
