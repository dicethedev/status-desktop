import configs.path
import driver.local_system
from gui.elements.base_element import BaseElement
from gui.elements.button import Button


class ChangeLanguagePopup(BaseElement):

    def __init__(self):
        super(ChangeLanguagePopup, self).__init__('statusDesktop_mainWindow_overlay')
        self._close_the_app_button = Button('close_the_app_now_StatusButton')

    def close_app(self):
        self._close_the_app_button.click()
        driver.local_system.wait_for_close(configs.path.AUT.name)
