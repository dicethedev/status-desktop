import os
import typing
from datetime import datetime

from src.scripts.utils.path import Path

ROOT: Path = Path(__file__).resolve().parent.parent

# Application Directories
AUT: Path = Path(os.getenv('AUT_PATH', ROOT.parent.parent / 'bin' / 'nim_status_client'))
STATUS_DATA: Path = ROOT / 'Status' / 'data'

# Test Directories
RUN_ID = os.getenv('RUN_DIR', f'run_{datetime.now(): %d%m%Y_%H%M%S}')
TEMP: Path = ROOT / 'tmp'
RESULTS: Path = TEMP / 'results'
RUN: Path = RESULTS / RUN_ID
VP: Path = ROOT / 'exe' / 'vp'
UI_IMG: Path = VP / 'ui_img'
# Runtime initialisation
TEST: typing.Optional[Path] = None
TEST_VP: typing.Optional[Path] = None
TEST_ARTIFACTS: typing.Optional[Path] = None
