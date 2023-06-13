import logging

import driver
from constants.user import UserAccount
from driver import settings
from gui.components.before_started_popup import BeforeStartedPopUp
from gui.components.splash_screen import SplashScreen
from gui.elements.base_element import BaseElement
from gui.elements.base_window import BaseWindow
from gui.elements.button import Button
from gui.screens.messages import MessagesScreen
from gui.screens.onboarding import WelcomeScreen, AllowNotificationsView
from gui.screens.settings import SettingsScreen

_logger = logging.getLogger(__name__)


class NavigationPanel(BaseElement):

    def __init__(self):
        super(NavigationPanel, self).__init__('mainWindow_StatusAppNavBar')
        self._messages_button = Button('messages_navbar_StatusNavBarTabButton')
        self._communities_portal_button = Button('communities_Portal_navbar_StatusNavBarTabButton')
        self._wallet_button = Button('wallet_navbar_StatusNavBarTabButton')
        self._settings_button = Button('settings_navbar_StatusNavBarTabButton')

    def open_messages_screen(self):
        self._messages_button.click()
        return MessagesScreen().wait_until_appears()

    def open_communities_portal(self):
        self._communities_portal_button.click()

    def open_wallet(self):
        self._wallet_button.click()

    def open_settings(self) -> SettingsScreen:
        self._settings_button.click()
        return SettingsScreen().wait_until_appears()


class MainWindow(BaseWindow):

    def __init__(self):
        super(MainWindow, self).__init__('statusDesktop_mainWindow')
        self._secure_your_seed_phrase_banner = BaseElement('secureYourSeedPhraseBanner_ModuleWarning')
        self.welcome_screen = WelcomeScreen()
        self.navigator = NavigationPanel()

    def is_secure_phrase_banner_visible(self):
        return self._secure_your_seed_phrase_banner.is_visible

    def sign_up_user(self, user_account: UserAccount):
        if driver.local_system.is_mac():
            AllowNotificationsView().wait_until_appears().allow()
        BeforeStartedPopUp().get_started()
        self.welcome_screen.sign_up(user_account)
        return self

    def log_in_user(self, user_account: UserAccount):
        self.welcome_screen.log_in(user_account)
        return self
