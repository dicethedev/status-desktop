import os

from utils.system_path import SystemPath

ROOT: SystemPath = SystemPath(__file__).resolve().parent.parent.parent
TMP: SystemPath = ROOT / 'tmp'

AUT: SystemPath = SystemPath(os.getenv('AUT_PATH', '/home/squisher/Downloads/StatusIm-Desktop-230531-065943-a07f91-pr10871-x86_64/StatusIm-Desktop-230531-065943-a07f91-pr10871-x86_64.AppImage'))
STATUS_DATA_FOLDER_NAME = 'Status'
