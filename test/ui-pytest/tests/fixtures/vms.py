import logging
import time
from contextlib import contextmanager

import portalocker
import pytest

import configs.local
import constants
import driver
from configs.path import VM_SQUISH_DIR, VMS, VM_STATUS_DESKTOP, SQUISH_DIR, QT_DIR, VM_QT_DIR
from constants.vbox import VMState
from driver.virtual_box import VirtualBox
from driver.worker import VirtualMachine

vm1 = True
vm2 = True


vms = [True, True]
vm_names = [f'ubuntu22-0{index}' for index in range(1, configs.local.WORKERS_LIMIT+1)]

_logger = logging.getLogger(__name__)


@pytest.fixture(scope='session')
def vms():
    if not configs.local.LOCAL_RUN:
        vb = VirtualBox()
        vm_base_name = 'ubuntu22-0'
        if len(vb.vms) != configs.local.WORKERS_LIMIT:
            for index in range(1, configs.local.WORKERS_LIMIT+1):
                if f'{vm_base_name}{index}' in [info.name for info in vb.vms]:
                    continue
                else:
                    vb.create_vm(f'{vm_base_name}{index}', index)


@contextmanager
def locked_vm():
    for vm_name in vm_names:
        lock_path = VMS / vm_name / f'{vm_name}.lock'
        try:
            with portalocker.utils.Lock(lock_path, fail_when_locked=True):
                _logger.info(f'{vm_name} taken')
                yield vm_name
                _logger.info(f'{vm_name} released')
                lock_path.unlink()
                break
        except portalocker.exceptions.AlreadyLocked:
            _logger.info(f'{vm_name} already taken')
            continue
    raise RuntimeError('Reached limit of VMs')


@pytest.fixture
def linux_vm():
    vb = VirtualBox()
    try:
        with locked_vm() as vm_name:
            vm = VirtualMachine(
                name=vm_name,
                aut_port=vb.get_port_forward(vm_name, driver.settings.SERVER_PORT),
                ssh_port=vb.get_port_forward(vm_name, 22)
            )

            vm.mont_shared_folder(VM_STATUS_DESKTOP.name, VM_STATUS_DESKTOP)
            vm.mont_shared_folder(SQUISH_DIR.name, VM_SQUISH_DIR)
            vm.mont_shared_folder(QT_DIR.name, VM_QT_DIR)

            vm_state = vb.get_vm_state(vm_name)
            if VMState.PAUSED.value in vm_state:
                vb.resume_vm(vm_name)
            elif VMState.RUNNING.value not in vm_state:
                vb.start_vm(vm_name)
            yield vm
    except RuntimeError:
        time.sleep(1)
