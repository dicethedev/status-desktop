import time
import typing

import driver
from gui.elements.base_element import BaseElement
from gui.elements.button import Button
from gui.elements.list import List
from gui.elements.text_edit import TextEdit


class LeftPanel(BaseElement):

    def __init__(self):
        super(LeftPanel, self).__init__('mainWindow_Control')
        self._start_chat_button = Button('mainWindow_startChat')
        self._contact_list_item = BaseElement('chatListItems_DropArea')

    @property
    def contacts(self) -> typing.List[str]:
        if 'objectName' in self._contact_list_item.real_name:
            del self._contact_list_item.real_name['objectName']
        items = driver.findAllObjects(self._contact_list_item.real_name)
        return [str(getattr(item, 'objectName', '')) for item in items]

    def open_create_chat_view(self) -> 'CreateChatView':
        self._start_chat_button.click(x=1, y=1)
        return CreateChatView().wait_until_appears()

    def open_chat_with(self, contact_name: str):
        self._contact_list_item.real_name['objectName'] = contact_name
        self._contact_list_item.click(x=1, y=1)
        return ChatView().wait_until_appears()


class CreateChatView(BaseElement):

    def __init__(self):
        super(CreateChatView, self).__init__('mainWindow_ChatColumnView')
        self._contacts_list = List('createChatView_contactsList')
        self._confirm_button = Button('createChatView_confirmBtn')

    def select_user(self, name: str):
        self._contacts_list.select(name, 'userName')

    def create_chat(self, members: typing.List[str]):
        # Select members:
        for member in members:
            # Sleep important bc the list changes its content after selecting a user so, it needs a while to be updated
            time.sleep(0.2)
            self.select_user(member)

        # Confirm creation:
        self._confirm_button.click()
        return ChatView().wait_until_appears()


class ChatView(BaseElement):

    def __init__(self):
        super(ChatView, self).__init__('mainWindow_ChatColumnView')
        self._info_button = Button('chatView_StatusChatInfoButton')
        self._message_text_edit = TextEdit('chatView_messageInput')
        self._messages_log_list = List('chatView_log')

    @property
    def title(self) -> str:
        return str(self._info_button.object.title)

    @property
    def messages(self) -> typing.List[str]:
        return self._messages_log_list.get_values('messageText')

    def send_message(self, message: str):
        self._message_text_edit.type_text(message)
        driver.type(self._message_text_edit.object, "<Return>")


class MessagesScreen(BaseElement):

    def __init__(self):
        super(MessagesScreen, self).__init__('mainWindow_ChatView')
        self.left_panel = LeftPanel()
