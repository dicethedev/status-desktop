from gui.elements.qt.object import QObject
from gui.elements.qt.button import Button


class TestnetModeBanner(QObject):
    def __init__(self):
        super(TestnetModeBanner, self).__init__('mainWindow_testnetBanner_ModuleWarning')
        self._turn_off_button = Button('mainWindow_Turn_off_Button')
