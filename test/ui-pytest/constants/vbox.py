from enum import Enum

template = 'ubuntu22-2.vdi'


class VMState(Enum):
    RUNNING = 'VMState="running"'
    PAUSED = 'VMState="paused"'
