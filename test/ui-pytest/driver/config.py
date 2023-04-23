import os

from driver.system_path import SystemPath

ROOT: SystemPath = SystemPath(__file__).resolve().parent.parent

CURSOR_ANIMATION = int(os.getenv('CURSOR_ANIMATION', 0))

INSTALL_DIR = SystemPath(os.getenv('SQUISH_DIR'))
SERVER = INSTALL_DIR / 'bin' / 'squishserver'
RUNNER = INSTALL_DIR / 'bin' / 'startaut'
SERVER_CONFIG = ROOT / 'squish_server.ini'

AUT_WRAPPER = 'Qt'

SERVER_HOST = os.getenv('SERVER_HOST', '127.0.0.1')
SERVER_PORT = os.getenv('SERVER_PORT', 4322)

PROCESS_TIMEOUT_SEC = 10
APP_LOAD_TIMEOUT_MSEC = 60000
UI_LOAD_TIMEOUT_MSEC = 5000

EXECUTABLE_AUT_PORT = os.getenv("AUT_PORT", 61500)
ATTACHABLE_AUT_PORT = os.getenv('ATTACHABLE_AUT', 62500)
ATTACHABLE_AUT_ID = 'AUT'

ATTACH_MODE = False
