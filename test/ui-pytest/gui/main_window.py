from gui.objects_map import main_window_names as names
from gui.screens.onboarding import WelcomeScreen
from gui.wrappers.py_button import PyButton
from gui.wrappers.py_element import PyElement
from gui.wrappers.py_window import PyWindow


class NavigationPanel(PyElement):

    def __init__(self):
        super(NavigationPanel, self).__init__(names.mainWindow_StatusAppNavBar)
        self._messages_button = PyButton(names.messages_navbar_StatusNavBarTabButton)
        self._communities_portal_button = PyButton(names.communities_Portal_navbar_StatusNavBarTabButton)
        self._wallet_button = PyButton(names.wallet_navbar_StatusNavBarTabButton)
        self._settings_button = PyButton(names.settings_navbar_StatusNavBarTabButton)

    def open_message_screen(self):
        self._messages_button.click()

    def open_communities_screen(self):
        self._communities_portal_button.click()

    def open_wallet_screen(self):
        self._wallet_button.click()

    def open_settings_screen(self):
        self._settings_button.click()


class MainWindow(PyWindow):

    def __init__(self):
        super(MainWindow, self).__init__(names.statusDesktop_mainWindow)
        self.welcome_screen = WelcomeScreen()
        self.navigator = NavigationPanel()
