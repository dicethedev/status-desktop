import logging
import os
import pathlib

_logger = logging.getLogger(__name__)


class Path(pathlib.Path):
    _accessor = None
    _flavour = pathlib._windows_flavour if os.name == 'nt' else pathlib._posix_flavour  # noqa

    def rmtree(self, ignore_errors=False):
        children = list(self.iterdir())
        for child in children:
            if child.is_dir():
                child.rmtree(ignore_errors=ignore_errors)
            else:
                try:
                    child.unlink()
                except OSError as e:
                    _logger.info(e)
                    if not ignore_errors:
                        raise
        try:
            self.rmdir()
            _logger.info(f'Directory removed: "{str(self)}"')
        except OSError as e:
            _logger.info(e)
            if not ignore_errors:
                raise
