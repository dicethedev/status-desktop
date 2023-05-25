import logging
import os
import pathlib

_logger = logging.getLogger(__name__)


class SystemPath(pathlib.Path):
    _accessor = pathlib._normal_accessor  # noqa
    _flavour = pathlib._windows_flavour if os.name == 'nt' else pathlib._posix_flavour  # noqa

    def rmtree(self, ignore_errors=False):
        try:
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
            self.rmdir()
            _logger.info(f'Directory removed: "{str(self)}"')
        except (FileNotFoundError, OSError) as e:
            _logger.info(e)
            if not ignore_errors:
                raise

    def copy_to(self, destination: 'SystemPath'):
        _logger.info("Copy from %s to %s", self, destination)
        if not destination.exists():
            destination.mkdir(parents=True)
        destination.write_bytes(self.read_bytes())
