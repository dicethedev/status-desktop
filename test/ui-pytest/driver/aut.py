from datetime import datetime

import squish

import configs
import driver
from driver import config, context, server, local_system
from driver.system_path import SystemPath
from gui.elements.base_window import BaseWindow


class BaseAut:

    def __init__(self):
        self.ctx = None

    def __str__(self):
        return type(self).__qualname__

    def attach(self, aut_id: str = None, timeout_sec: int = driver.config.PROCESS_TIMEOUT_SEC):
        if self.ctx is None or not self.ctx.isRunning:
            self.ctx = context.attach(aut_id, timeout_sec)
        squish.setApplicationContext(self.ctx)
        return self

    def detach(self):
        context.detach()
        self.ctx = None
        return self


class ExecutableAut(BaseAut):

    def __init__(self, fp: SystemPath):
        super(ExecutableAut, self).__init__()
        self.fp = fp
        server.add_executable_aut(fp.name, fp.parent)
        squish.testSettings.setWrappersForApplication(fp.name, [driver.config.AUT_WRAPPER])

    @property
    def start_command_args(self) -> list:
        return []

    def start(self, *args) -> 'ExecutableAut':
        if config.ATTACH_MODE:
            server.add_attachable_aut(self.fp.stem, self.aut_port)
            args = [
                       config.RUNNER,
                       f'--port={self.aut_port}',
                       f'"{self.fp}"'
                   ] + args

            local_system.execute(args)
            self.attach(self.fp.stem)
        else:
            cmd = ' '.join([self.fp.name] + [str(arg) for arg in args])
            self.ctx = squish.startApplication(cmd)
            squish.setApplicationContext(self.ctx)

        assert squish.waitFor(lambda: self.ctx.isRunning, driver.config.APP_LOAD_TIMEOUT_MSEC)

        return self

