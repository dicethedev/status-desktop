import logging
from abc import ABC

import squish

import configs
from scripts.tools.squish_api import context

_logger = logging.getLogger(__name__)


class AbstractAut(ABC):

    def __init__(self, aut_id, aut_port):
        self.aut_id = aut_id
        self.aut_port = aut_port
        self.ctx = None

    def attach(self, aut_id, timeout_sec: int = configs.squish.PROCESS_TIMEOUT_SEC):
        if self.ctx is None or not self.ctx.isRunning:
            self.ctx = context.attach(aut_id, timeout_sec)
        squish.setApplicationContext(self.ctx)
        return self

    def detach(self):
        context.detach()
        return self
