import logging
import os
import pathlib
import shutil
import time

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

    def copy_to(self, destination: 'SystemPath', chunk_size: int = 1**10):
        _logger.info(f'Copy from {self} to {destination}')
        if self.is_file():
            with self.open('rb') as source_file:
                with destination.open('wb') as destination_path:
                    while True:
                        chunk = source_file.read(chunk_size)
                        if not chunk:
                            break
                        destination_path.write(chunk)
        else:
            shutil.copytree(self, destination, dirs_exist_ok=True)
