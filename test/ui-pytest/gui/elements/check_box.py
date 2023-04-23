import driver
from gui.elements import BaseElement


class CheckBox(BaseElement):

    def set(self, value: bool, x: int = None, y: int = None):
        if self.is_checked is not value:
            self.click(x, y)
            assert driver.waitFor(
                lambda: self.is_checked is value, driver.config.UI_LOAD_TIMEOUT_MSEC), 'Value not changed'
