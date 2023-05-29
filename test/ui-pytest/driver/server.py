import typing

from driver import settings, local_system, remote_system

_PROCESS_NAME = '_squishserver'


def start():
    local_system.execute([settings.SERVER, '--configfile', settings.SERVER_CONFIG, '--verbose', '&'])
    local_system.wait_for_started(_PROCESS_NAME, 3)


def stop():
    local_system.kill_process_by_name(_PROCESS_NAME)


def prepare_config():
    if settings.SERVER_CONFIG.exists():
        settings.SERVER_CONFIG.unlink()
    set_cursor_animation(settings.CURSOR_ANIMATION)
    set_aut_timeout(settings.APP_LOAD_TIMEOUT_MSEC)


# https://doc-snapshots.qt.io/squish/cli-squishserver.html
def configuring(action: str, options: typing.Union[int, str, list]):
    command = [settings.SERVER, '--configfile', str(settings.SERVER_CONFIG), '--config', action, options]
    remote_system.execute(command)


def set_cursor_animation(value):
    configuring('setCursorAnimation', value)


def add_executable_aut(aut_id, app_dir):
    configuring('addAUT', [aut_id, app_dir])


def add_attachable_aut(aut_id: str, port: int):
    configuring('addAttachableAUT', [aut_id, f'localhost: {port}'])


def set_aut_timeout(value):
    configuring('setAUTTimeout', value)
