import os

AUT_WRAPPER = 'Qt'

SERVER_HOST = os.getenv('SERVER_HOST', '127.0.0.1')
SERVER_PORT = os.getenv('SERVER_PORT', 4322)

PROCESS_TIMEOUT_SEC = 30
APP_LOAD_TIMEOUT_MSEC = 240000
UI_LOAD_TIMEOUT_MSEC = 5000

# Limit of multiple instances
AUT_PORT_RANGE = [61500, 62500]
ATTACH_MODE = False
