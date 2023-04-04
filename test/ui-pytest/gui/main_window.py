import logging

from gui.objects_map import main_window_names as names
from gui.screens.onboarding import WelcomeScreen
from gui.screens.settings import SettingsScreen
from gui.wrappers.py_button import PyButton
from gui.wrappers.py_element import PyElement
from gui.wrappers.py_window import PyWindow

_logger = logging.getLogger(__name__)


class NavigationPanel(PyElement):

    def __init__(self):
        super(NavigationPanel, self).__init__(names.mainWindow_StatusAppNavBar)
        self._messages_button = PyButton(names.messages_navbar_StatusNavBarTabButton)
        self._communities_portal_button = PyButton(names.communities_Portal_navbar_StatusNavBarTabButton)
        self._wallet_button = PyButton(names.wallet_navbar_StatusNavBarTabButton)
        self._settings_button = PyButton(names.settings_navbar_StatusNavBarTabButton)

    def open_message(self):
        self._messages_button.click()

    def open_communities_portal(self):
        self._communities_portal_button.click()

    def open_wallet(self):
        self._wallet_button.click()

    def open_settings(self):
        self._settings_button.click()
        settings = SettingsScreen().wait_until_appears()
        _logger.info('Settings screen open')
        return settings


class MainWindow(PyWindow):

    def __init__(self):
        super(MainWindow, self).__init__(names.statusDesktop_mainWindow)
        self._secure_your_seed_phrase_banner = PyElement(names.secureYourSeedPhraseBanner_ModuleWarning)
        self.welcome_screen = WelcomeScreen()
        self.navigator = NavigationPanel()

    def is_secure_phrase_banner_visible(self):
        return self._secure_your_seed_phrase_banner.is_visible
