from abc import ABC

import squish

from driver import config, context, server, local_system, remote_system, system_path


class AbstractAut(ABC):

    def __init__(self, aut_id, aut_port):
        self.aut_id = aut_id
        self.aut_port = aut_port
        self.ctx = None

    def __str__(self):
        return type(self).__qualname__

    def attach(self, aut_id, timeout_sec: int = config.PROCESS_TIMEOUT_SEC):
        if self.ctx is None or not self.ctx.isRunning:
            self.ctx = context.attach(aut_id, timeout_sec)
        squish.setApplicationContext(self.ctx)
        return self

    def detach(self):
        context.detach()
        return self


class AttachableAut(AbstractAut, ABC):

    def __init__(
            self,
            aut_id: str = config.ATTACHABLE_AUT_ID,
            aut_port: int = config.ATTACHABLE_AUT_PORT
    ):
        super(AttachableAut, self).__init__(aut_id, aut_port)
        server.add_attachable_aut(aut_id, aut_port)
        squish.testSettings.setWrappersForApplication(aut_id, [config.AUT_WRAPPER])

    def attach_to_process(self, process_id: int):
        remote_system.execute(
            [
                config.RUNNER,
                f'--port={self.aut_port}',
                f'--pid={process_id}'
            ]
        )
        return super(AttachableAut, self).attach(self.aut_id)

    def attach_to_window(self, title: str):
        remote_system.execute(
            [
                config.RUNNER,
                f'--port={self.aut_port}',
                f'"--window-title={title}"'
            ]
        )
        return super(AttachableAut, self).attach(self.aut_id)


class ExecutableAut(AbstractAut, ABC):

    def __init__(self, fp: system_path.SystemPath, aut_port: int = config.EXECUTABLE_AUT_PORT):
        self.fp = fp
        super(ExecutableAut, self).__init__(fp.name, aut_port)
        server.add_executable_aut(fp.name, fp.parent)
        squish.testSettings.setWrappersForApplication(fp.name, [config.AUT_WRAPPER])

    @property
    def start_command_args(self) -> list:
        return []

    def start(self):
        if config.ATTACH_MODE:
            squish.tools.server.add_attachable_aut(self.aut_id, self.aut_port)
            args = [
                       config.RUNNER,
                       f'--port={self.aut_port}',
                       f'"{self.fp}"'
                   ] + self.start_command_args

            local_system.execute(args)
            self.attach(self.aut_id)
        else:
            args = ' '.join(self.start_command_args + [self.aut_id])
            self.ctx = squish.startApplication(args)
            assert squish.waitFor(lambda: self.ctx.isRunning, config.APP_LOAD_TIMEOUT_MSEC)

    def close(self):
        local_system.kill_process_by_name(self.aut_id)
        return self

    def wait_for_close(self):
        local_system.wait_for_close(self.aut_id)
