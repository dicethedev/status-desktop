import os
import typing
from datetime import datetime

from driver.system_path import SystemPath

# Runtime initialisation
TEST: typing.Optional[SystemPath] = None
TEST_VP: typing.Optional[SystemPath] = None
TEST_ARTIFACTS: typing.Optional[SystemPath] = None

ROOT: SystemPath = SystemPath(__file__).resolve().parent.parent
USER_HOME: SystemPath = SystemPath.home()
WORKPLACE: SystemPath = USER_HOME / 'Workspace'
SQUISH_DIR = SystemPath(os.getenv('SQUISH_DIR'), WORKPLACE/'squish')
QT_DIR = WORKPLACE / 'Qt'

# Test Directories
RUN_ID = os.getenv('RUN_DIR', f'run_{datetime.now():%d%m%Y_%H%M%S}')
TEMP: SystemPath = ROOT / 'tmp'
RESULTS: SystemPath = TEMP / 'results'
RUN: SystemPath = RESULTS / RUN_ID
VP: SystemPath = ROOT / 'exe' / 'vps'
UI_IMG: SystemPath = VP / 'ui_img'

# Application Directories
AUT: SystemPath = SystemPath(os.getenv('AUT_PATH', ROOT.parent.parent / 'bin' / 'nim_status_client'))
STATUS_DATA: SystemPath = RUN / 'status'

# TODO: move to submodule
STATUS_USER_COMMUNITY_MEMBERS_DATA: SystemPath = ROOT.parent / 'ui-test' / 'fixtures' / 'community_members'
STATUS_USER_MUTUAL_CONTACTS_DATA: SystemPath = ROOT.parent / 'ui-test' / 'fixtures' / 'mutual_contacts'

# Virtual Box
VMS: SystemPath = USER_HOME / 'VirtualBox VMs'
VM_TEMPLATE_DISK = VMS / 'templates'

VM_WORKPLACE = SystemPath('/home/squisher/test')
VM_TMP = VM_WORKPLACE / 'tmp'
VM_STATUS_DATA = VM_TMP / 'status'

VM_MNT_DIR = SystemPath('/mnt')
VM_SQUISH_DIR = VM_MNT_DIR / 'squish'
VM_QT_DIR = VM_MNT_DIR / 'qt'
VM_STATUS_DESKTOP = VM_MNT_DIR / 'status_desktop'
VM_AUT = VM_STATUS_DESKTOP / 'bin' / AUT.name


