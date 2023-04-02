import squish

import configs.squish
from gui.wrappers.py_element import PyElement


class PyCheckBox(PyElement):

    def set(self, value: bool, x: int = None, y: int = None):
        if self.is_checked is not value:
            self.click(x, y)
            assert squish.waitFor(
                lambda: self.is_checked is value, configs.squish.UI_LOAD_TIMEOUT_SEC * 1000), 'Value not changed'
