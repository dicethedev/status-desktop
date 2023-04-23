import logging

from gui.elements import BaseElement, Button
from gui.elements.base_window import BaseWindow
from gui.screens.onboarding import WelcomeScreen
from gui.screens.settings import SettingsScreen

_logger = logging.getLogger(__name__)


class NavigationPanel(BaseElement):

    def __init__(self):
        super(NavigationPanel, self).__init__('mainWindow_StatusAppNavBar')
        self._messages_button = Button('messages_navbar_StatusNavBarTabButton')
        self._communities_portal_button = Button('communities_Portal_navbar_StatusNavBarTabButton')
        self._wallet_button = Button('wallet_navbar_StatusNavBarTabButton')
        self._settings_button = Button('settings_navbar_StatusNavBarTabButton')

    def open_message(self):
        self._messages_button.click()

    def open_communities_portal(self):
        self._communities_portal_button.click()

    def open_wallet(self):
        self._wallet_button.click()

    def open_settings(self) -> SettingsScreen:
        self._settings_button.click()
        settings = SettingsScreen().wait_until_appears()
        return settings


class MainWindow(BaseWindow):

    def __init__(self):
        super(MainWindow, self).__init__('statusDesktop_mainWindow')
        self._secure_your_seed_phrase_banner = BaseElement('secureYourSeedPhraseBanner_ModuleWarning')
        self.welcome_screen = WelcomeScreen()
        self.navigator = NavigationPanel()

    def is_secure_phrase_banner_visible(self):
        return self._secure_your_seed_phrase_banner.is_visible
