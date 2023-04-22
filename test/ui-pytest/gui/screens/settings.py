from gui.components.back_up_your_seed_phrase_popup import BackUpYourSeedPhrasePopUp
from gui.components.send_contact_request_popup import SendContactRequestPopup
from gui.elements.base_element import BaseElement
from gui.elements.button import Button


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

    def start_back_up_seed_phrase(self) -> BackUpYourSeedPhrasePopUp:
        self._back_up_seed_phrase_item.click()
        return BackUpYourSeedPhrasePopUp().wait_until_appears()

    def open_messaging_settings(self) -> 'MessagingView':
        self._messaging_item.click()
        return MessagingView().wait_until_appears()


class SettingsScreen(BaseElement):

    def __init__(self):
        super(SettingsScreen, self).__init__('mainWindow_mainRightView_ColumnLayout')
        self.menu_panel = MenuPanel()


class BaseSettingsView(BaseElement):
    pass


class ProfileView(BaseSettingsView):

    def __init__(self):
        super(ProfileView, self).__init__('mainWindow_ProfileSettingsView')


class WalletView(BaseSettingsView):

    def __init__(self):
        super(WalletView, self).__init__('mainWindow_WalletView')


class MessagingView(BaseSettingsView):

    def __init__(self):
        super(MessagingView, self).__init__('mainWindow_MessagingView')
        self._contacts_button = Button('contacts_listItem_btn')

    def open_contacts_settings(self):
        self._contacts_button.click()
        return ContactsView().wait_until_appears()


class ContactsView(BaseSettingsView):

    def __init__(self):
        super(ContactsView, self).__init__('mainWindow_ContactsView')
        self._contact_request_to_chat_key_button = Button('contact_request_to_chat_key_btn')
        self._pending_requests_tab_button = Button('contactRequest_PendingRequests_Button')
        self._sent_requests_list = BaseElement('sentRequests_contactListPanel_ListView')

    @property
    def pending_requests(self):
        self._pending_requests_tab_button.click()
        contact_keys = []
        contact_list = self._sent_requests_list.object
        for index in range(contact_list.count):
            contact = contact_list.itemAtIndex(index)
            contact_keys.append(str(contact.compressedPk))
        return contact_keys

    def add_contact_by_chat_key(self, chat_key: str, who_you_are: str):
        self._contact_request_to_chat_key_button.click()
        SendContactRequestPopup().fill_form_and_send(chat_key=chat_key, who_you_are=who_you_are)
