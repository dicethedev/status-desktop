from . main_window_names import *

mainWindow_onboardingBackButton_StatusRoundButton = {"container": statusDesktop_mainWindow, "objectName": "onboardingBackButton", "type": "StatusRoundButton", "visible": True}

# Welcome View
mainWindow_WelcomeView = {"container": statusDesktop_mainWindow, "type": "WelcomeView", "unnamed": 1, "visible": True}
mainWindow_I_am_new_to_Status_StatusBaseText = {"container": mainWindow_WelcomeView, "objectName": "welcomeViewIAmNewToStatusButton", "type": "StatusButton"}
mainWindow_I_already_use_Status_StatusBaseText = {"container": mainWindow_WelcomeView, "objectName": "welcomeViewIAlreadyUseStatusButton", "type": "StatusFlatButton", "visible": True}

# Get Keys View
mainWindow_KeysMainView = {"container": statusDesktop_mainWindow, "type": "KeysMainView", "unnamed": 1, "visible": True}
mainWindow_Generate_new_keys_StatusButton = {"checkable": False, "container": mainWindow_KeysMainView, "objectName": "keysMainViewPrimaryActionButton", "type": "StatusButton", "visible": True}

# Insert Details View
mainWindow_InsertDetailsView = {"container": statusDesktop_mainWindow, "type": "InsertDetailsView", "unnamed": 1, "visible": True}
mainWindow_statusBaseInput_StatusBaseInput = {"container": mainWindow_InsertDetailsView, "objectName": "onboardingDisplayNameInput", "type": "TextEdit"}
mainWindow_Next_StatusButton = {"checkable": False, "container": mainWindow_InsertDetailsView, "objectName": "onboardingDetailsViewNextButton", "text": "Next", "type": "StatusButton", "visible": True}

# Create Password View
mainWindow_CreatePasswordView = {"container": statusDesktop_mainWindow, "type": "CreatePasswordView", "unnamed": 1, "visible": True}
mainWindow_passwordViewNewPassword = {"container": statusDesktop_mainWindow, "echoMode": 2, "objectName": "passwordViewNewPassword", "type": "StatusPasswordInput", "visible": True}
mainWindow_passwordViewNewPasswordConfirm = {"container": statusDesktop_mainWindow, "echoMode": 2, "objectName": "passwordViewNewPasswordConfirm", "type": "StatusPasswordInput", "visible": True}
mainWindow_Create_password_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow, "objectName": "onboardingCreatePasswordButton", "text": "Create password", "type": "StatusButton", "visible": True}

# Confirm Password View
mainWindow_ConfirmPasswordView = {"container": statusDesktop_mainWindow, "type": "ConfirmPasswordView", "unnamed": 1,"visible": True}
mainWindow_confirmAgainPasswordInput = {"container": mainWindow_ConfirmPasswordView, "echoMode": 2, "objectName": "confirmAgainPasswordInput", "passwordCharacter": "•", "type": "StatusPasswordInput", "visible": True}
mainWindow_Finalise_Status_Password_Creation_StatusButton = {"checkable": False, "container": mainWindow_ConfirmPasswordView, "objectName": "confirmPswSubmitBtn", "type": "StatusButton", "visible": True}

# Loading View
mainWindow_appLoadingAnimation_Loader = {"container": statusDesktop_mainWindow, "id": "appLoadingAnimation", "type": "Loader", "unnamed": 1, "visible": True}