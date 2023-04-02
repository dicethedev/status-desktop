import logging
from abc import ABC

import squish

import configs
from scripts.tools.aut.abstract_aut import AbstractAut
from scripts.tools.squish_api import squish_server, remote_system

_logger = logging.getLogger(__name__)


class AttachableAut(AbstractAut, ABC):

    def __init__(
            self,
            aut_id: str = configs.squish.ATTACHABLE_AUT_ID,
            aut_port: int = configs.squish.ATTACHABLE_AUT_PORT
    ):
        super(AttachableAut, self).__init__(aut_id, aut_port)
        squish_server.add_attachable_aut(aut_id, aut_port)
        squish.testSettings.setWrappersForApplication(aut_id, [configs.squish.AUT_WRAPPER])

    def attach_to_process(self, process_id: int):
        remote_system.execute(
            [
                configs.squish.RUNNER,
                f'--port={self.aut_port}',
                f'--pid={process_id}'
            ]
        )
        return super(AttachableAut, self).attach(self.aut_id)

    def attach_to_window(self, title: str):
        remote_system.execute(
            [
                configs.squish.RUNNER,
                f'--port={self.aut_port}',
                f'"--window-title={title}"'
            ]
        )
        return super(AttachableAut, self).attach(self.aut_id)
