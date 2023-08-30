import configs

from gui.components.base_popup import BasePopup
from gui.elements.qt.text_edit import TextEdit
from gui.elements.qt.object import QObject


class EmojiPopup(BasePopup):
    def __init__(self):
        super(EmojiPopup, self).__init__()
        self._search_text_edit = TextEdit('mainWallet_AddEditAccountPopup_AccountEmojiSearchBox')
        self._emoji_item = QObject('mainWallet_AddEditAccountPopup_AccountEmoji')

    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._search_text_edit.wait_until_appears(timeout_msec)
        return self

    def select(self, name: str):
        self._search_text_edit.text = name
        self._emoji_item.real_name['objectName'] = 'statusEmoji_' + name
        self._emoji_item.click()
        self._search_text_edit.wait_until_hidden()