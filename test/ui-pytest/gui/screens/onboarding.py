import time
from abc import abstractmethod

import configs
import constants
from constants.user import UserAccount
from gui.components.splash_screen import SplashScreen
from gui.elements.base_element import BaseElement
from gui.elements.button import Button
from gui.elements.text_field import TextEdit


class WelcomeScreen(BaseElement):

    def __init__(self):
        super(WelcomeScreen, self).__init__('mainWindow_WelcomeView')
        self._new_user_button = Button('mainWindow_I_am_new_to_Status_StatusBaseText')
        self._existing_user_button = Button('mainWindow_I_already_use_Status_StatusBaseText')

    def sign_up(self, user_account: UserAccount = constants.user_account_1):
        self.get_keys() \
            .generate_new_keys() \
            .set_display_name(user_account.name) \
            .next() \
            .next() \
            .create_password(user_account.password) \
            .confirm_password(user_account.password)
        SplashScreen().wait_until_appears().wait_until_hidden(configs.squish.APP_LOAD_TIMEOUT_MSEC)

    def get_keys(self) -> 'KeysScreen':
        self._new_user_button.click()
        time.sleep(1)
        return KeysScreen().wait_until_appears()

    def sign_in(self):
        self._existing_user_button.click()
        # TODO: return next view

    def log_in(self, account: UserAccount = constants.user_account_1):
        LoginView().log_in(account)
        SplashScreen().wait_until_appears().wait_until_hidden()


class OnboardingBaseScreen(BaseElement):

    def __init__(self, object_name):
        super(OnboardingBaseScreen, self).__init__(object_name)
        self._back_button = Button('mainWindow_onboardingBackButton_StatusRoundButton')

    @abstractmethod
    def back(self):
        pass


class KeysScreen(OnboardingBaseScreen):

    def __init__(self):
        super(KeysScreen, self).__init__('mainWindow_KeysMainView')
        self._generate_key_button = Button('mainWindow_Generate_new_keys_StatusButton')

    def generate_new_keys(self) -> 'DetailsView':
        self._generate_key_button.click()
        return DetailsView().wait_until_appears()

    def back(self) -> WelcomeScreen:
        self._back_button.click()
        return WelcomeScreen().wait_until_appears()


class DetailsView(OnboardingBaseScreen):

    def __init__(self):
        super(DetailsView, self).__init__('mainWindow_InsertDetailsView')
        self._display_name_text_field = TextEdit('mainWindow_statusBaseInput_StatusBaseInput')
        self._next_button = Button('mainWindow_Next_StatusButton')

    def set_display_name(self, value: str):
        self._display_name_text_field.clear().text = value
        return self

    def next(self) -> 'DetailsView2':
        self._next_button.click()
        time.sleep(1)
        return DetailsView2()

    def back(self):
        self._back_button.click()
        return KeysScreen().wait_until_appears()


class DetailsView2(DetailsView):

    def next(self) -> 'CreatePasswordView':
        self._next_button.click()
        time.sleep(1)
        return CreatePasswordView().wait_until_appears()

    def back(self):
        self._back_button.click()
        return DetailsView().wait_until_appears()


class CreatePasswordView(OnboardingBaseScreen):

    def __init__(self):
        super(CreatePasswordView, self).__init__('mainWindow_CreatePasswordView')
        self._new_password_text_field = TextEdit('mainWindow_passwordViewNewPassword')
        self._confirm_password_text_field = TextEdit('mainWindow_passwordViewNewPasswordConfirm')
        self._create_button = Button('mainWindow_Create_password_StatusButton')

    def create_password(self, value: str) -> 'ConfirmPasswordView':
        self._new_password_text_field.clear().text = value
        self._confirm_password_text_field.clear().text = value
        self._create_button.click()
        time.sleep(1)
        return ConfirmPasswordView().wait_until_appears()

    def back(self):
        self._back_button.click()
        return DetailsView2().wait_until_appears()


class ConfirmPasswordView(OnboardingBaseScreen):

    def __init__(self):
        super(ConfirmPasswordView, self).__init__('mainWindow_ConfirmPasswordView')
        self._confirm_password_text_field = TextEdit('mainWindow_confirmAgainPasswordInput')
        self._confirm_button = Button('mainWindow_Finalise_Status_Password_Creation_StatusButton')

    def confirm_password(self, value: str):
        self._confirm_password_text_field.text = value
        self._confirm_button.click()

    def back(self):
        self._back_button.click()
        return CreatePasswordView().wait_until_appears()


class LoginView(BaseElement):

    def __init__(self):
        super(LoginView, self).__init__('mainWindow_LoginView')
        self._password_text_edit = TextEdit('loginView_passwordInput')
        self._arrow_right_button = Button('loginView_submitBtn')

    def log_in(self, account):
        self._password_text_edit.text = account.password
        self._arrow_right_button.click()
        self.wait_until_hidden()
