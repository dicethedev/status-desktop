import logging
from abc import ABC

import squish

import configs
from src.scripts.tools.aut.abstract_aut import AbstractAut
from src.scripts.tools.squish_api import squish_server
from src.scripts.utils import local_system
from src.scripts.utils.path import Path

_logger = logging.getLogger(__name__)


class ExecutableAut(AbstractAut, ABC):

    def __init__(self, fp: Path, aut_port: int = configs.squish.EXECUTABLE_AUT_PORT):
        self.fp = fp
        super(ExecutableAut, self).__init__(fp.name, aut_port)
        squish_server.add_executable_aut(fp.name, fp.parent)
        squish.testSettings.setWrappersForApplication(fp.name, [configs.squish.AUT_WRAPPER])

    @property
    def start_command_args(self) -> list:
        return []

    def start(self):
        if configs.squish.ATTACH_MODE:
            squish_server.add_attachable_aut(self.aut_id, self.aut_port)
            args = [
                       configs.squish.RUNNER,
                       f'--port={self.aut_port}',
                       f'"{self.fp}"'
                   ] + self.start_command_args

            local_system.execute(args)
            self.attach(self.aut_id)
        else:
            args = ' '.join(self.start_command_args + [self.aut_id])
            self.ctx = squish.startApplication(args)
            assert squish.waitFor(lambda: self.ctx.isRunning, configs.squish.APP_LOAD_TIMEOUT_SEC)

    def close(self):
        local_system.kill_process_by_name(self.aut_id)
        return self

    def wait_for_close(self):
        local_system.wait_for_close(self.aut_id)
