from .main_window_names import statusDesktop_mainWindow

mainWindow_navBarListView_ListView = {"container": statusDesktop_mainWindow, "objectName": "statusMainNavBarListView", "type": "ListView", "visible": True}
mainWindow_ScrollView = {"container": statusDesktop_mainWindow, "type": "StatusScrollView", "unnamed": 1, "visible": True}
mainWindow_mainRightView_ColumnLayout = {"container": statusDesktop_mainWindow, "objectName": "mainRightView", "type": "ColumnLayout", "visible": True}

# Navigation
mainWindow_StatusScrollView = {"container": mainWindow_mainRightView_ColumnLayout, "type": "StatusScrollView", "unnamed": 1, "visible": True}
mainWindow_Settings_StatusNavigationPanelHeadline = {"container": mainWindow_StatusScrollView, "type": "StatusNavigationPanelHeadline", "unnamed": 1, "visible": True}
o0_MainMenuItem_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": "0-MainMenuItem", "type": "StatusNavigationListItem", "visible": True}
o2_MainMenuItem_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": "2-MainMenuItem", "type": "StatusNavigationListItem", "visible": True}
o3_AppMenuItem_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": "3-AppMenuItem", "type": "StatusNavigationListItem", "visible": True}
o4_AppMenuItem_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": "4-AppMenuItem", "type": "StatusNavigationListItem", "visible": True}
o5_SettingsMenuItem_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": "5-SettingsMenuItem", "type": "StatusNavigationListItem", "visible": True}
o6_SettingsMenuItem_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": "6-SettingsMenuItem", "type": "StatusNavigationListItem", "visible": True}
o7_SettingsMenuItem_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": "7-SettingsMenuItem", "type": "StatusNavigationListItem", "visible": True}
o8_MainMenuItem_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": "8-MainMenuItem", "type": "StatusNavigationListItem", "visible": True}
o10_SettingsMenuItem_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": "10-SettingsMenuItem", "type": "StatusNavigationListItem", "visible": True}
o11_ExtraMenuItem_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": "11-ExtraMenuItem", "type": "StatusNavigationListItem", "visible": True}
o12_AppMenuItem_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": "12-AppMenuItem", "type": "StatusNavigationListItem", "visible": True}
o13_MainMenuItem_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": "13-MainMenuItem", "type": "StatusNavigationListItem", "visible": True}
o14_ExtraMenuItem_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": "14-ExtraMenuItem", "type": "StatusNavigationListItem", "visible": True}
o15_MainMenuItem_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": "15-MainMenuItem", "type": "StatusNavigationListItem", "visible": True}

# Profile View
mainWindow_ProfileSettingsView = {"container": statusDesktop_mainWindow, "objectName": "myProfileSettingsView", "type": "MyProfileSettingsView", "visible": True}

# Messaging View
mainWindow_MessagingView = {"container": statusDesktop_mainWindow, "type": "MessagingView", "unnamed": 1, "visible": True}
contacts_listItem_btn = {"container": mainWindow_MessagingView, "objectName": "MessagingView_ContactsListItem_btn", "type": "StatusContactRequestsIndicatorListItem"}

# Contacts View
mainWindow_ContactsView = {"container": statusDesktop_mainWindow, "type": "ContactsView", "unnamed": 1, "visible": True}
contact_request_to_chat_key_btn = {"container": mainWindow_ContactsView, "objectName": "ContactsView_ContactRequest_Button", "type": "StatusButton"}
contactRequest_PendingRequests_Button = {"container": mainWindow_ContactsView, "objectName": "ContactsView_PendingRequest_Button", "type": "StatusTabButton"}
sentRequests_ContactsListPanel = {"container": mainWindow_ContactsView, "objectName": "sentRequests_ContactsListPanel", "type": "ContactsListPanel"}
sentRequests_contactListPanel_ListView = {"container": sentRequests_ContactsListPanel, "objectName": "ContactListPanel_ListView", "type": "StatusListView"}

# Language View
settings_LanguageView = {"container": statusDesktop_mainWindow, "objectName": "languageView", "type": "LanguageView"}
languageView_language_StatusListPicker = {"container": settings_LanguageView, "objectName": "languagePicker", "type": "StatusListPicker"}
languageView_language_StatusPickerButton = {"container": languageView_language_StatusListPicker,  "type": "StatusPickerButton", "unnamed": 1}
languageView_language_ListView = {"container": languageView_language_StatusListPicker,  "type": "ListView", "unnamed": 1}
languageView_language_StatusInput = {"container": languageView_language_ListView, "type": "TextEdit", "unnamed": 1, "visible": True}

mainWindow_profileContainer_StackLayout = {"container": statusDesktop_mainWindow, "id": "profileContainer", "type": "StackLayout", "unnamed": 1, "visible": True}

mainWindow_keycardView_Loader = {"container": statusDesktop_mainWindow, "id": "keycardView", "type": "Loader", "unnamed": 1, "visible": True}
mainWindow_AppearanceView = {"container": statusDesktop_mainWindow, "type": "AppearanceView", "unnamed": 1, "visible": True}

# Wallet View
mainWindow_WalletView = {"container": mainWindow_StatusScrollView, "type": "WalletView", "unnamed": 1, "visible": True}

