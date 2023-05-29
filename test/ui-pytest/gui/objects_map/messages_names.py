from . main_window_names import *

mainWindow_ChatView = {"container": statusDesktop_mainWindow, "type": "ChatView", "unnamed": 1, "visible": True}
mainWindow_ChatColumnView = {"container": mainWindow_ChatView, "type": "ChatColumnView", "unnamed": 1, "visible": True}

# Left Panel
mainWindow_ContactsColumnView = {"container": mainWindow_ChatView, "type": "ContactsColumnView", "unnamed": 1, "visible": True}
mainWindow_chatListItems_StatusListView = {"container": mainWindow_ContactsColumnView, "objectName": "chatListItems", "type": "StatusListView", "visible": True}
chatListItems_DropArea = {"container": mainWindow_chatListItems_StatusListView, "type": "DropArea", "visible": True}
mainWindow_Control = {"container": mainWindow_ChatView, "type": "Control", "unnamed": 1, "visible": True}
mainWindow_startChat = {"checkable": True, "container": mainWindow_Control, "objectName": "startChatButton", "type": "StatusIconTabButton"}
chatList = {"container": statusDesktop_mainWindow, "objectName": "ContactsColumnView_chatList", "type": "StatusChatList"}

# Create chat view:
createChatView_contactsList = {"container": statusDesktop_mainWindow, "objectName": "createChatContactsList", "type": "StatusListView"}
createChatView_confirmBtn = {"container": statusDesktop_mainWindow, "objectName": "inlineSelectorConfirmButton", "type": "StatusButton"}

# Chat View
chatView_StatusChatInfoButton = {"container": statusDesktop_mainWindow, "objectName": "chatInfoBtnInHeader", "type": "StatusChatInfoButton", "visible": True}
chatView_messageInput = {"container": statusDesktop_mainWindow, "objectName": "messageInputField", "type": "TextArea", "visible": True}
chatView_log = {"container": statusDesktop_mainWindow, "objectName": "chatLogView", "type": "StatusListView", "visible": True}
