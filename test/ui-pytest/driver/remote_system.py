import logging

import remotesystem

from . import config

_logger = logging.getLogger(__name__)


def execute(command: list):
    _logger.info(f'Remote Execute: {" ".join(str(atr) for atr in command)}')
    exitcode, stdout, stderr = remotesystem.RemoteSystem(
        host=config.SERVER_HOST, port=config.SERVER_PORT
    ).execute(command)
    if exitcode != '0':
        raise RuntimeError(f'exitcode: {exitcode}, stdout: {stdout}, stderr: {stderr}')
