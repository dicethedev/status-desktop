import logging

from remotesystem import RemoteSystem

import configs

_logger = logging.getLogger(__name__)


def execute(command: list):
    _logger.info(f'Remote Execute: {" ".join(str(atr) for atr in command)}')
    exitcode, stdout, stderr = RemoteSystem(
        host=configs.squish.SERVER_HOST, port=configs.squish.SERVER_PORT
    ).execute(command)
    if exitcode != '0':
        raise RuntimeError(f'exitcode: {exitcode}, stdout: {stdout}, stderr: {stderr}')
