import signal
import subprocess

import squish

from driver import settings, server, context, system_path, local_system


class ApplicationLauncher:

    def __init__(self, app_path: system_path.SystemPath):
        super(ApplicationLauncher, self).__init__()
        self.app_path = app_path
        self.ctx = None

        server.add_executable_aut(app_path.stem, app_path.parent)
        squish.testSettings.setWrappersForApplication(app_path.stem, [settings.AUT_WRAPPER])

    def __str__(self):
        return type(self).__qualname__

    def attach(self, aut_id: str = None, timeout_sec: int = settings.PROCESS_TIMEOUT_SEC):
        if self.ctx is None:
            self.ctx = context.attach(aut_id, timeout_sec)
        squish.setApplicationContext(self.ctx)
        return self

    def detach(self):
        if self.ctx is not None:
            squish.currentApplicationContext().detach()
            assert squish.waitFor(lambda: not self.ctx.isRunning, settings.APP_LOAD_TIMEOUT_MSEC)
        self.ctx = None
        return self

    def stop(self):
        local_system.kill_process_by_name(self.app_path.name)

    @staticmethod
    def get_aut_port():
        for port in settings.AUT_PORT_RANGE:
            if not local_system.find_process_by_port(port):
                return port
        raise RuntimeError('Port not found, increase the port count in "driver.setting.AUT_PORT_RANGE"')

    def launch(self, *args) -> 'ApplicationLauncher':
        if settings.ATTACH_MODE:
            aut_port = self.get_aut_port()
            server.add_attachable_aut(self.app_path.stem, aut_port)
            command = [
                       settings.RUNNER,
                       f'--port={aut_port}',
                       f'"{self.app_path}"'
                   ] + list(args)

            local_system.execute(command)
            self.attach(self.app_path.stem)
        else:
            command = [self.app_path.name] + list(args)
            self.ctx = squish.startApplication(' '.join(command))

        assert squish.waitFor(lambda: self.ctx.isRunning, settings.APP_LOAD_TIMEOUT_MSEC)
        return self
