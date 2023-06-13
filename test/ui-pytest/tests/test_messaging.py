import pytest

import driver
from driver import settings
from driver.aut import ApplicationLauncher
import configs
import constants
from driver.system_path import SystemPath
from gui.components.splash_screen import SplashScreen
from gui.main_window import MainWindow

@pytest.mark.skip
# Test Case: https://ethstatus.testrail.net/index.php?/cases/view/703011
@pytest.mark.case(703011)
@pytest.mark.parametrize('user_data, user_data_two, message', [
    pytest.param(
        configs.path.STATUS_USER_MUTUAL_CONTACTS_DATA,
        configs.path.STATUS_USER_MUTUAL_CONTACTS_DATA,
        'Test message',
        id='chat')
], indirect=['user_data', 'user_data_two'])
def test_one_to_one_chat(user_data: SystemPath, user_data_two: SystemPath, message):
    aut_one = ApplicationLauncher(configs.path.AUT).launch(f'-d={user_data.parent}')
    main_window_one = MainWindow().wait_until_appears().prepare()
    main_window_one.log_in_user(constants.user.user_account_one)
    SplashScreen().wait_until_appears().wait_until_hidden(settings.APP_LOAD_TIMEOUT_MSEC)

    aut_two = ApplicationLauncher(configs.path.AUT).launch(f'-d={user_data_two.parent}')
    main_window_two = MainWindow().wait_until_appears().prepare()
    main_window_two.log_in_user(constants.user.user_account_two)
    SplashScreen().wait_until_appears().wait_until_hidden(settings.APP_LOAD_TIMEOUT_MSEC)
    main_window_two.minimize()

    aut_one.attach()
    messages_screen = main_window_one.navigator.open_messages_screen()
    chat_view = messages_screen.left_panel.open_create_chat_view().create_chat([constants.user.user_account_two.name])
    assert driver.waitFor(lambda: chat_view.title == constants.user.user_account_two.name)
    chat_view.send_message(message)
    assert driver.waitFor(lambda: message in chat_view.messages[0], settings.UI_LOAD_TIMEOUT_MSEC)
    main_window_one.minimize()

    aut_two.attach()
    main_window_two.maximize()
    messages_screen = main_window_two.navigator.open_messages_screen()
    driver.waitFor(lambda: constants.user.user_account_one.name in messages_screen.left_panel.contacts,
                   settings.APP_LOAD_TIMEOUT_MSEC), f'contact not found in {messages_screen.left_panel.contacts}'
    chat_view = messages_screen.left_panel.open_chat_with(constants.user.user_account_one.name)
    assert driver.waitFor(lambda: message in chat_view.messages[0], settings.APP_LOAD_TIMEOUT_MSEC)
