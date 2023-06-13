import logging
import time

import paramiko
import remotesystem

import configs.path
import constants
import driver.settings
from configs.vm_env import variables
from constants.user import user_account
from driver import local_system
from driver.server import SquishServer
from driver.system_path import SystemPath

_logger = logging.getLogger(__name__)


class BaseWorker:

    def __init__(
            self,
            install_dir: SystemPath = configs.path.SQUISH_DIR,
            host: str = driver.settings.SERVER_HOST, port: int = driver.settings.SERVER_PORT
    ):
        self.server = SquishServer(squish_dir=install_dir, host=host, port=port)
        self.system: remotesystem.RemoteSystem = None
        self.install_dir = install_dir
        self.host = host
        self.port = port

    def upload(self, local_source: SystemPath, destination: SystemPath):
        assert self.system.copy(str(local_source), str(destination))


class VirtualMachine(BaseWorker):

    def __init__(
            self,
            name: str,
            install_dir: SystemPath = configs.path.VM_SQUISH_DIR,
            aut_port: int = driver.settings.SERVER_PORT,
            ssh_port: int = 22
    ):
        super(VirtualMachine, self).__init__(install_dir)
        self.name = name
        self.aut_port = aut_port
        self.ssh_port = ssh_port
        self.path = configs.path.VMS / self.name
        self.disk = self.path / f'{self.name}.vdi'
        self.config = self.path / f'{self.name}.vbox'

    def get_ssh_client(self):
        ssh_client = paramiko.client.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect(
            self.host, self.ssh_port,
            username=constants.user.user_account.name,
            password=constants.user.user_account.password,
            allow_agent=False,
            look_for_keys=False,
            timeout=10
        )
        return ssh_client

    def execute(self, command, sudo: bool = False, verify: bool = True, timeout_sec=10):
        timeout = ['timeout', f'{timeout_sec}s'] if timeout_sec else []
        auth = ['sudo', '-S', '<<<', f'"{constants.user.user_account.password}"'] if sudo else []
        cmd = ' '.join(str(arg) for arg in timeout + auth + command)
        _logger.info(f'Executing: {cmd}')
        ssh_client = self.get_ssh_client()
        chan = ssh_client.get_transport().open_session()
        chan.exec_command(cmd)
        ssh_client.close()
        if timeout_sec:
            exit_status = chan.recv_exit_status()
            err = str(chan.recv_stderr(5000))
            return exit_status

    def start_squish_server(self):
        self.execute(['mkdir', '-p', self.server.config.parent])
        self.execute(['cat', '>', self.server.config], timeout_sec=2)
        # self.execute(self.server.get_stop_cmd(), sudo=True)
        # self.execute(self.server.get_start_cmd(), timeout_sec=0)
        pass

    def setup_squish_config(self, aut_path: SystemPath):
        self.execute(self.server.get_executable_aut_setup_cmd(aut_path.stem, aut_path.parent))
        self.execute(self.server.get_aut_timeout_setup_cmd(60))

    def upload_file(self, local_file: SystemPath, vm_file_path: SystemPath, executable: bool = False):
        ftp_client = self.get_ssh_client().open_sftp()
        try:
            ftp_client.remove(str(vm_file_path / local_file.stem))
        except FileNotFoundError:
            pass
        ftp_client.put(str(local_file), str(vm_file_path / local_file.stem))
        if executable:
            ftp_client.chmod(str(vm_file_path / local_file.stem), 111)
        ftp_client.close()

    def mont_shared_folder(self, name, path):
        self.execute(['mkdir', path], sudo=True)
        self.execute(['mount', '-t', 'vboxsf', name, path], sudo=True)

    def set_environment_variables(self):
        for key, value in variables.items():
            self.execute(['export', f'{key}={value}'], sudo=True)
            pass


class LocalMachine(BaseWorker):

    def __init__(self):
        super(LocalMachine, self).__init__()

    def execute(self, command):
        _logger.info(f'Remote Execute: {" ".join(str(atr) for atr in command)}')
        exitcode, stdout, stderr = self.system.execute(command)
        if exitcode != '0':
            raise RuntimeError(f'exitcode: {exitcode}, stdout: {stdout}, stderr: {stderr}')

    def start_squish_server(self):
        local_system.execute(self.server.get_stop_cmd())
        local_system.execute(self.server.get_start_cmd())
