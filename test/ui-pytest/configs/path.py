import os
import typing
from datetime import datetime

from driver.system_path import SystemPath

# Runtime initialisation
TEST: typing.Optional[SystemPath] = None
TEST_VP: typing.Optional[SystemPath] = None
TEST_ARTIFACTS: typing.Optional[SystemPath] = None

ROOT: SystemPath = SystemPath(__file__).resolve().parent.parent


# Test Directories
RUN_ID = os.getenv('RUN_DIR', f'run_{datetime.now():%d%m%Y_%H%M%S}')
TEMP: SystemPath = ROOT / 'tmp'
RESULTS: SystemPath = TEMP / 'results'
RUN: SystemPath = RESULTS / RUN_ID
STATUS_DATA: SystemPath = RUN / 'status'
VP: SystemPath = ROOT / 'exe' / 'vp'
UI_IMG: SystemPath = VP / 'ui_img'

# Application Directories
AUT: SystemPath = SystemPath(os.getenv('AUT_PATH', ROOT.parent.parent / 'bin' / 'nim_status_client'))
STATUS_USER_COMMUNITY_MEMBERS_DATA: SystemPath = ROOT.parent / 'ui-test' / 'fixtures' / 'community_members'
STATUS_USER_MUTUAL_CONTACTS_DATA: SystemPath = ROOT.parent / 'ui-test' / 'fixtures' / 'mutual_contacts'
