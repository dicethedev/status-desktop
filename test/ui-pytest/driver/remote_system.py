import logging

import remotesystem

from . import settings

_logger = logging.getLogger(__name__)


def execute(command: list):
    _logger.info(f'Remote Execute: {" ".join(str(atr) for atr in command)}')
    exitcode, stdout, stderr = remotesystem.RemoteSystem(
        host=settings.SERVER_HOST, port=settings.SERVER_PORT
    ).execute(command)
    if exitcode != '0':
        raise RuntimeError(f'exitcode: {exitcode}, stdout: {stdout}, stderr: {stderr}')
