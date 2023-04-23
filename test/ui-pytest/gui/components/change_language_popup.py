from gui.elements import BaseElement, Button


class ChangeLanguagePopup(BaseElement):

    def __init__(self):
        super(ChangeLanguagePopup, self).__init__('statusDesktop_mainWindow_overlay')
        self._close_the_app_button = Button('close_the_app_now_StatusButton')

    def close_app(self):
        self._close_the_app_button.click()
