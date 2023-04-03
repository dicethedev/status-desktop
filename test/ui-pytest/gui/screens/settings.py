from gui.objects_map import settings_names as names
from gui.wrappers.py_element import PyElement


class MenuPanel(PyElement):

    def __init__(self):
        super(MenuPanel, self).__init__(names.mainWindow_StatusScrollView)
        self._back_up_seed_phrase_item = PyElement(names.o15_MainMenuItem_StatusNavigationListItem)
        self._profile_item = PyElement(names.o0_MainMenuItem_StatusNavigationListItem)
        self._key_card_item = PyElement(names.o13_MainMenuItem_StatusNavigationListItem)
        self._ens_usernames_item = PyElement(names.o2_MainMenuItem_StatusNavigationListItem)
        self._syncing_item = PyElement(names.o8_MainMenuItem_StatusNavigationListItem)
        self._messaging_item = PyElement(names.o3_AppMenuItem_StatusNavigationListItem)
        self._wallet_item = PyElement(names.o4_AppMenuItem_StatusNavigationListItem)
        self._communities_item = PyElement(names.o12_AppMenuItem_StatusNavigationListItem)
        self._appearance_item = PyElement(names.o5_SettingsMenuItem_StatusNavigationListItem)
        self._notifications_item = PyElement(names.o7_SettingsMenuItem_StatusNavigationListItem)
        self._language_item = PyElement(names.o6_SettingsMenuItem_StatusNavigationListItem)
        self._advanced_item = PyElement(names.o10_SettingsMenuItem_StatusNavigationListItem)
        self._about_item = PyElement(names.o11_ExtraMenuItem_StatusNavigationListItem)
        self._sign_out_quit_item = PyElement(names.o14_ExtraMenuItem_StatusNavigationListItem)

    def back_up_seed_phrase(self):
        self._back_up_seed_phrase_item.click()
        return


class SettingsScreen(PyElement):

    def __init__(self):
        super(SettingsScreen, self).__init__(names.mainWindow_mainRightView_ColumnLayout)
        self.menu_panel = MenuPanel()


class WalletView(PyElement):

    def __init__(self):
        super(WalletView, self).__init__(names.mainWindow_WalletView)
