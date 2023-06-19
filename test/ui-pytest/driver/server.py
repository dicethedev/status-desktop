import typing

import configs
import driver.settings
from configs.path import SQUISH_DIR, SQUISH_CFG
from driver.system_path import SystemPath

_PROCESS_NAME = '_squishserver'


class SquishServer:

    def __init__(
            self,
            squish_dir: SystemPath = SQUISH_DIR,
            host: str = '127.0.0.1',
            port: int = driver.settings.SERVER_PORT
    ):
        self.path = squish_dir / 'bin' / 'squishserver'
        self.config = SQUISH_CFG
        self.host = host
        self.port = port

    def get_start_cmd(self):
        return [str(self.path), '--configfile', str(self.config), f'--port={self.port}']

    def get_stop_cmd(self):
        return ['killall', _PROCESS_NAME]

    # https://doc-snapshots.qt.io/squish/cli-squishserver.html
    def configuring(self, action: str, options: typing.Union[int, str, list]):
        return [str(self.path), '--configfile', str(self.config), '--config', action, ' '.join(options)]

    def get_cursor_setup_cmd(self, value):
        return self.configuring('setCursorAnimation', value)

    def get_executable_aut_setup_cmd(self, aut_id, app_dir):
        return self.configuring('addAUT', [aut_id, f'"{app_dir}"'])

    def get_attachable_aut_setup_cmd(self, aut_id: str, port: int):
        return self.configuring('addAttachableAUT', [aut_id, f'localhost: {port}'])

    def get_aut_timeout_setup_cmd(self, value):
        return self.configuring('setAUTTimeout', [str(value)])
