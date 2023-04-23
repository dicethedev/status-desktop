from gui.elements import BaseElement, TextEdit, Button


class SendContactRequestPopup(BaseElement):

    def __init__(self):
        super(SendContactRequestPopup, self).__init__('statusDesktop_mainWindow_overlay')
        self._chat_key_text_edit = TextEdit('contactRequest_ChatKey_Input')
        self._say_who_you_are_text_edit = TextEdit('contactRequest_SayWhoYouAre_Input')
        self._send_button = Button('contactRequest_Send_Button')

    @property
    def chat_key(self):
        return self._chat_key_text_edit.text

    @chat_key.setter
    def chat_key(self, value: str):
        self._chat_key_text_edit.text = value

    @property
    def who_you_are(self):
        return self._say_who_you_are_text_edit.text

    @who_you_are.setter
    def who_you_are(self, value: str):
        self._say_who_you_are_text_edit.text = value

    def fill_form_and_send(self, **kwargs):
        for key, value in kwargs.items():
            setattr(self, key, value)
        self._send_button.click()
        self.wait_until_hidden()
