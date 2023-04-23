import typing

from driver import config, local_system, remote_system

_PROCESS_NAME = '_squishserver'


def start():
    local_system.execute([config.SERVER, '--configfile', config.SERVER_CONFIG, '--verbose', '&'])
    local_system.wait_for_started(_PROCESS_NAME, 3)


def stop():
    local_system.kill_process_by_name(_PROCESS_NAME)


def prepare_config():
    if config.SERVER_CONFIG.exists():
        config.SERVER_CONFIG.unlink()
    set_cursor_animation(config.CURSOR_ANIMATION)
    set_aut_timeout(config.APP_LOAD_TIMEOUT_MSEC)


# https://doc-snapshots.qt.io/squish/cli-squishserver.html
def configuring(action: str, options: typing.Union[int, str, list]):
    command = [config.SERVER, '--configfile', str(config.SERVER_CONFIG), '--config', action, options]
    remote_system.execute(command)


def set_cursor_animation(value):
    configuring('setCursorAnimation', value)


def add_executable_aut(aut_id, app_dir):
    configuring('addAUT', [aut_id, app_dir])


def add_attachable_aut(aut_id: str, port: int):
    configuring('addAttachableAUT', [aut_id, f'localhost: {port}'])


def set_aut_timeout(value):
    configuring('setAUTTimeout', value)
