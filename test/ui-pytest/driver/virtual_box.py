import logging
import os
import subprocess
import time
import typing
import uuid
from collections import namedtuple
from copy import deepcopy
from math import floor, log
from string import ascii_lowercase, digits
from xml.etree import ElementTree

import paramiko

import configs.path
import constants
import driver
from configs.vm_env import variables
from constants.vbox import VMState
from driver.worker import VirtualMachine
from driver.system_path import SystemPath

_logger = logging.getLogger(__name__)

vm_info = namedtuple('Virtual_machineInfo', ['name', 'state'])


class VirtualBox:

    def __init__(self):
        self.path = self.name = 'VBoxManage'
        self.pack_name = 'Oracle VM VirtualBox Extension Pack'
        self.vm_config = ElementTree.parse(str(configs.path.ROOT / 'configs' / 'ubuntu.vbox'))
        assert self.is_installed, 'VirtualBox not installed'
        assert self.is_extension_pack_installed, f'{self.pack_name} not installed'
        self.ports_base = 20000

    @property
    def is_installed(self) -> bool:
        return subprocess.run(
            ['which', self.name],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        ).returncode == 0

    @property
    def is_extension_pack_installed(self) -> bool:
        return self.pack_name in self.execute(['VBoxManage', 'list', 'extpacks'])

    @property
    def vms(self) -> typing.List[vm_info]:
        output = self.execute(['VBoxManage', 'list', 'vms'])
        lines = output.splitlines()
        result = []
        for line in lines:
            name = line.replace('"', '').split('{')[0].strip()
            state = self.get_vm_state(name)
            result.append(vm_info(name, state))
        return result

    @classmethod
    def execute(cls, command: typing.List[str]) -> str:
        _logger.info(f'Executing: {command}')
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        with process:
            stdout, stderr = process.communicate(timeout=15)
            if process.returncode == 0:
                return stdout.decode('ascii')
            raise RuntimeError(str(stderr))

    def prepare_config(self, vm: VirtualMachine):
        _xml_ns = {'vbox': 'http://www.virtualbox.org/'}
        config_template = ElementTree.parse(str(configs.path.ROOT / 'configs' / 'ubuntu.vbox'))
        tree = deepcopy(config_template)
        machine = tree.find('./vbox:Machine', _xml_ns)
        machine.attrib['name'] = vm.name
        machine.attrib['uuid'] = str(name_to_uuid(vm.name))
        network = machine.find('./vbox:Hardware/vbox:Network', _xml_ns)
        adapters = network.findall('./vbox:Adapter', _xml_ns)
        for index, adapter in enumerate(adapters):
            mac = '0A:00:00:01:' + '{:02X}:'.format(int(vm.name.split('-')[1])) + '{:02X}'.format(index)
            adapter.attrib['MACAddress'] = mac.replace(':', '').replace('-', '')
        tree.write(vm.config)

    def setup_access(self, vm: VirtualMachine, index):
        ports_per_vm = 10
        ports_base = self.ports_base + ports_per_vm * index
        ports = range(ports_base, ports_base + ports_per_vm)
        gest_ports = {'tcp': {0: 22, 9: driver.settings.SERVER_PORT}}
        for protocol in gest_ports:
            for port_index, guest_port in gest_ports[protocol].items():
                host_port = ports[port_index]
                tag = '{}/{}'.format(protocol, guest_port)
                self.execute(
                    ['VBoxManage', 'modifyvm', vm.name, '--natpf1', f'{tag}, {protocol}, ,{host_port}, ,{guest_port}']
                )
        pass

    def create_vm(self, vm_name: str, index):
        template = constants.vbox.template
        vm = VirtualMachine(vm_name)
        if not vm.disk.exists():
            vm.path.mkdir(parents=True, exist_ok=True)
            vm_template_path = configs.path.VM_TEMPLATE_DISK / template
            if not vm_template_path.exists():
                self.fetch_disk_template(template)
            self.copy_vm_image(vm_template_path, vm.disk)
        self.prepare_config(vm)
        self.execute(['VBoxManage', 'registervm', str(vm.config)])
        self.execute([
            'VBoxManage', 'storageattach', vm.name, '--storagectl', 'SATA', '--device', '0', '--port', '0', '--type',
            'hdd', '--medium', str(vm.disk),
        ])
        self.execute(['VBoxManage', 'internalcommands', 'sethduuid', configs.path.VM_TEMPLATE_DISK / 'ubuntu22-2.vdi'])
        self.setup_access(vm, index)
        self.add_shared_folder(vm_name, configs.path.VM_STATUS_DESKTOP.name, configs.path.ROOT.parent.parent)
        self.add_shared_folder(vm_name, configs.path.VM_SQUISH_DIR.name, configs.path.SQUISH_DIR)
        self.add_shared_folder(vm_name, configs.path.VM_QT_DIR.name, configs.path.QT_DIR)

        return vm

    @classmethod
    def start_vm(cls, name):
        cls.execute(['VBoxManage', 'startvm', name, '--type', 'headless'])
        assert driver.waitFor(lambda: VMState.RUNNING.value in cls.get_vm_state(name))

    @classmethod
    def pause_vm(cls, name):
        if VMState.RUNNING.value in cls.get_vm_state(name):
            cls.execute(['VBoxManage', 'controlvm', name, 'pause'])
            assert driver.waitFor(lambda: VMState.PAUSED.value in cls.get_vm_state(name))

    @classmethod
    def resume_vm(cls, name):
        cls.execute(['VBoxManage', 'controlvm', name, 'resume'])
        assert driver.waitFor(lambda: VMState.RUNNING.value in cls.get_vm_state(name))

    @classmethod
    def stop_vm(cls, name):
        cls.execute(['VBoxManage', 'controlvm', name, 'poweroff'])
        assert driver.waitFor(lambda: VMState.RUNNING.value in cls.get_vm_state(name))

    @classmethod
    def fetch_disk_template(self, image_name: str):
        # TODO: download disk image
        pass

    @classmethod
    def get_vm_state(cls, name):
        return cls.execute(['VBoxManage', 'showvminfo', name, '--machinereadable'])

    @classmethod
    def vm_is_ready(cls, vm: VirtualMachine):
        started_at = time.monotonic()
        while True:
            try:
                vm.get_ssh_client().close()
                return True
            except paramiko.ssh_exception.SSHException as err:
                if time.monotonic() - started_at > 60:
                    return False

    @classmethod
    def get_port_forward(cls, vm_name,  port: int):
        info = cls.get_vm_state(vm_name)
        return info.split(f'tcp/{port},tcp,,')[1].split(f',,{port}')[0]

    def add_shared_folder(self, vm_name: str, name: str, folder_path: SystemPath):
        self.execute([
            'VBoxManage', 'sharedfolder', 'add', vm_name, f'--name={name}', f'--hostpath={folder_path}'
        ])

    @classmethod
    def copy_vm_image(cls, source_path: SystemPath, target_path: SystemPath):
        with source_path.open('rb') as source:
            with target_path.open('wb') as target_path:
                offset = 0
                while True:
                    copied = os.sendfile(
                        target_path.fileno(), source.fileno(), offset, 256 * 1024**2
                    )
                    if copied == 0:
                        break
                    offset += copied
                target_path.seek(0x188)
                target_path.write(uuid.uuid4().bytes_le)


def name_to_uuid(name):
    chars = ascii_lowercase + digits + '-'
    value = 0
    for char in name:
        value = value * len(chars) + chars.index(char)
    return uuid.UUID(int=value)
