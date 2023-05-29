import logging
import time

import squish

from driver import settings

_logger = logging.getLogger(__name__)


def attach(aut_name: str, timeout_sec: int = settings.PROCESS_TIMEOUT_SEC):
    _logger.info(f'Attaching squish to {aut_name}')
    started_at = time.monotonic()
    while True:
        try:
            context = squish.attachToApplication(aut_name)
            _logger.info(f'AUT: {aut_name} attached')
            return context
        except RuntimeError as err:
            _logger.info(err)
            time.sleep(1)
        assert time.monotonic() - started_at < timeout_sec, f'Attach error: {aut_name}'


def detach():
    for ctx in squish.applicationContextList():
        ctx.detach()
        assert squish.waitFor(lambda: not ctx.isRunning, settings.APP_LOAD_TIMEOUT_MSEC)
    _logger.info(f'All AUTs detached')
