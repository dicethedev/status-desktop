import os

from src.scripts.utils.path import Path

ROOT: Path = Path(__file__).resolve().parent.parent
AUT: Path = Path(os.getenv('AUT_PATH', ROOT.parent.parent / 'bin' / 'nim_status_client'))
STATUS_DATA: Path = ROOT / 'Status' / 'data'
