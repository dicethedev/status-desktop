from abc import abstractmethod

import configs
from gui.objects_map import onboarding_names as names
from gui.wrappers.py_button import PyButton
from gui.wrappers.py_element import PyElement
from gui.wrappers.py_text_field import PyTextField


class WelcomeScreen(PyElement):

    def __init__(self):
        super(WelcomeScreen, self).__init__(names.mainWindow_WelcomeView)
        self._new_user_button = PyButton(names.mainWindow_I_am_new_to_Status_StatusBaseText)
        self._existing_user_button = PyButton(names.mainWindow_I_already_use_Status_StatusBaseText)

    def get_keys(self) -> 'KeysScreen':
        self._new_user_button.click()
        return KeysScreen().wait_until_appears()

    def sign_in(self):
        self._existing_user_button.click()
        # TODO: return next view


class OnboardingBaseScreen(PyElement):

    def __init__(self, object_name):
        super(OnboardingBaseScreen, self).__init__(object_name)
        self._back_button = PyButton(names.mainWindow_onboardingBackButton_StatusRoundButton)

    @abstractmethod
    def back(self):
        pass


class KeysScreen(OnboardingBaseScreen):

    def __init__(self):
        super(KeysScreen, self).__init__(names.mainWindow_KeysMainView)
        self._generate_key_button = PyButton(names.mainWindow_Generate_new_keys_StatusButton)

    def generate_new_keys(self) -> 'DetailsView':
        self._generate_key_button.click()
        return DetailsView().wait_until_appears()

    def back(self) -> WelcomeScreen:
        self._back_button.click()
        return WelcomeScreen().wait_until_appears()


class DetailsView(OnboardingBaseScreen):

    def __init__(self):
        super(DetailsView, self).__init__(names.mainWindow_InsertDetailsView)
        self._display_name_text_field = PyTextField(names.mainWindow_statusBaseInput_StatusBaseInput)
        self._next_button = PyButton(names.mainWindow_Next_StatusButton)

    def set_display_name(self, value: str):
        self._display_name_text_field.clear().text = value
        return self

    def next(self) -> 'DetailsView2':
        self._next_button.click()
        return DetailsView2()

    def back(self):
        self._back_button.click()
        return KeysScreen().wait_until_appears()


class DetailsView2(DetailsView):

    def next(self) -> 'CreatePasswordView':
        self._next_button.click()
        return CreatePasswordView().wait_until_appears()

    def back(self):
        self._back_button.click()
        return DetailsView().wait_until_appears()


class CreatePasswordView(OnboardingBaseScreen):

    def __init__(self):
        super(CreatePasswordView, self).__init__(names.mainWindow_CreatePasswordView)
        self._new_password_text_field = PyTextField(names.mainWindow_passwordViewNewPassword)
        self._confirm_password_text_field = PyTextField(names.mainWindow_passwordViewNewPasswordConfirm)
        self._create_button = PyButton(names.mainWindow_Create_password_StatusButton)

    def create_password(self, value: str) -> 'ConfirmPasswordView':
        self._new_password_text_field.clear().text = value
        self._confirm_password_text_field.clear().text = value
        self._create_button.click()
        return ConfirmPasswordView().wait_until_appears()

    def back(self):
        self._back_button.click()
        return DetailsView2().wait_until_appears()


class ConfirmPasswordView(OnboardingBaseScreen):

    def __init__(self):
        super(ConfirmPasswordView, self).__init__(names.mainWindow_ConfirmPasswordView)
        self._confirm_password_text_field = PyTextField(names.mainWindow_confirmAgainPasswordInput)
        self._confirm_button = PyButton(names.mainWindow_Finalise_Status_Password_Creation_StatusButton)

    def confirm_password(self, value: str):
        self._confirm_password_text_field.text = value
        self._confirm_button.click()

    def back(self):
        self._back_button.click()
        return CreatePasswordView().wait_until_appears()


class SplashScreen(PyElement):

    def __init__(self):
        super(SplashScreen, self).__init__(names.splashScreen)

    def wait_until_hidden(self, timeout_sec: int = configs.squish.APP_LOAD_TIMEOUT_SEC):
        self.wait_until_appears()
        super(SplashScreen, self).wait_until_hidden(timeout_sec)
