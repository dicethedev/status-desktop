import driver
from gui.elements.base_element import BaseElement


class SplashScreen(BaseElement):

    def __init__(self):
        super(SplashScreen, self).__init__('splashScreen')

    def wait_until_appears(self, timeout_msec: int = driver.settings.UI_LOAD_TIMEOUT_MSEC):
        assert self.wait_for(lambda: self.exists, timeout_msec), f'Object {self} is not visible'
        return self

    def wait_until_hidden(self, timeout_msec: int = driver.settings.APP_LOAD_TIMEOUT_MSEC):
        super().wait_until_hidden(timeout_msec)
