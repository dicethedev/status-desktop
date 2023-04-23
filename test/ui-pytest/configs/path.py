import os
import typing
from datetime import datetime

from driver.system_path import SystemPath

ROOT: SystemPath = SystemPath(__file__).resolve().parent.parent

# Application Directories
AUT: SystemPath = SystemPath(os.getenv('AUT_PATH', ROOT.parent.parent / 'bin' / 'nim_status_client'))
STATUS_DATA: SystemPath = ROOT.parent.parent / 'Status'

# Test Directories
RUN_ID = os.getenv('RUN_DIR', f'run_{datetime.now(): %d%m%Y_%H%M%S}')
TEMP: SystemPath = ROOT / 'tmp'
RESULTS: SystemPath = TEMP / 'results'
RUN: SystemPath = RESULTS / RUN_ID
VP: SystemPath = ROOT / 'exe' / 'vp'
UI_IMG: SystemPath = VP / 'ui_img'
# Runtime initialisation
TEST: typing.Optional[SystemPath] = None
TEST_VP: typing.Optional[SystemPath] = None
TEST_ARTIFACTS: typing.Optional[SystemPath] = None
