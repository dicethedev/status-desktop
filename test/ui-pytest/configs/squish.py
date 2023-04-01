import os
from pathlib import Path

CURSOR_ANIMATION = int(os.getenv('CURSOR_ANIMATION', 0))

INSTALL_DIR = Path(os.getenv('SQUISH_DIR'))
SERVER_HOST = os.getenv('SERVER_HOST', '127.0.0.1')
SERVER_PORT = os.getenv('SERVER_PORT', 4322)

PROCESS_TIMEOUT_SEC = 10
APP_LOAD_TIMEOUT_SEC = 60
