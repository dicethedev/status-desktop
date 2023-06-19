import squish

from driver import settings, server, context, system_path, local_system


class ApplicationLauncher:

    def __init__(self, app_path: system_path.SystemPath, host: str, port: int):
        super(ApplicationLauncher, self).__init__()
        self.path = app_path
        self.host = host
        self.port = int(port)
        self.ctx = None

    def __str__(self):
        return type(self).__qualname__

    def attach(self, timeout_sec: int = settings.PROCESS_TIMEOUT_SEC, attempt: int = 2):
        if self.ctx is None:
            self.ctx = context.attach(self.path.stem, timeout_sec)
        try:
            squish.setApplicationContext(self.ctx)
        except TypeError as err:
            if attempt:
                return self.attach(timeout_sec, attempt - 1)
            else:
                raise err

    def detach(self):
        if self.ctx is not None:
            squish.currentApplicationContext().detach()
            assert squish.waitFor(lambda: not self.ctx.isRunning, settings.PROCESS_TIMEOUT_SEC)
        self.ctx = None
        return self

    def stop(self, verify: bool = True):
        local_system.kill_process_by_name(self.path.name, verify=verify)

    @staticmethod
    def get_aut_port():
        for port in settings.AUT_PORT_RANGE:
            if not local_system.find_process_by_port(port):
                return port
        raise RuntimeError('Port not found, increase the port count in "driver.setting.AUT_PORT_RANGE"')

    def launch(self, *args) -> 'ApplicationLauncher':
        # if settings.ATTACH_MODE:
        #     aut_port = self.get_aut_port()
        #     server.add_attachable_aut(self.app_path.stem, aut_port)
        #     command = [
        #                settings.RUNNER,
        #                f'--port={aut_port}',
        #                f'"{self.app_path}"'
        #            ] + list(args)
        #
        #     local_system.execute(command)
        # else:
        command = [self.path.stem] + list(args)

        self.ctx = squish.startApplication(' '.join(command), self.host, self.port, settings.PROCESS_TIMEOUT_SEC)
        self.attach()
        assert squish.waitFor(lambda: self.ctx.isRunning, settings.PROCESS_TIMEOUT_SEC)
        return self
