from gui.components.back_up_your_seed_phrase_popup import BackUpYourSeedPhrasePopUp
from gui.elements.base_element import BaseElement


class MenuPanel(BaseElement):

    def __init__(self):
        super(MenuPanel, self).__init__('mainWindow_StatusScrollView')
        self._back_up_seed_phrase_item = BaseElement('o15_MainMenuItem_StatusNavigationListItem')
        self._profile_item = BaseElement('o0_MainMenuItem_StatusNavigationListItem')
        self._key_card_item = BaseElement('o13_MainMenuItem_StatusNavigationListItem')
        self._ens_usernames_item = BaseElement('o2_MainMenuItem_StatusNavigationListItem')
        self._syncing_item = BaseElement('o8_MainMenuItem_StatusNavigationListItem')
        self._messaging_item = BaseElement('o3_AppMenuItem_StatusNavigationListItem')
        self._wallet_item = BaseElement('o4_AppMenuItem_StatusNavigationListItem')
        self._communities_item = BaseElement('o12_AppMenuItem_StatusNavigationListItem')
        self._appearance_item = BaseElement('o5_SettingsMenuItem_StatusNavigationListItem')
        self._notifications_item = BaseElement('o7_SettingsMenuItem_StatusNavigationListItem')
        self._language_item = BaseElement('o6_SettingsMenuItem_StatusNavigationListItem')
        self._advanced_item = BaseElement('o10_SettingsMenuItem_StatusNavigationListItem')
        self._about_item = BaseElement('o11_ExtraMenuItem_StatusNavigationListItem')
        self._sign_out_quit_item = BaseElement('o14_ExtraMenuItem_StatusNavigationListItem')

    def start_back_up_seed_phrase(self):
        self._back_up_seed_phrase_item.click()
        return BackUpYourSeedPhrasePopUp().wait_until_appears()


class SettingsScreen(BaseElement):

    def __init__(self):
        super(SettingsScreen, self).__init__('mainWindow_mainRightView_ColumnLayout')
        self.menu_panel = MenuPanel()


class WalletView(BaseElement):

    def __init__(self):
        super(WalletView, self).__init__('mainWindow_WalletView')
