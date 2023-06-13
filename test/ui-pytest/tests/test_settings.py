import pytest

import driver
from gui.components.before_started_popup import BeforeStartedPopUp
from gui.components.change_language_popup import ChangeLanguagePopup
from gui.components.splash_screen import SplashScreen
from gui.main_window import MainWindow
from gui.screens.onboarding import AllowNotificationsView
from gui.screens.settings import SettingsScreen


# Test Case: https://ethstatus.testrail.net/index.php?/cases/view/702389
@pytest.mark.case(702389)
def test_backup_seed_phrase(linux_vm, main_screen):
    assert main_screen.is_secure_phrase_banner_visible()
    settings: SettingsScreen = main_screen.navigator.open_settings()
    back_up_seed_phrase_popup = settings.menu_panel.start_back_up_seed_phrase()
    back_up_seed_phrase_popup.i_have_a_pen_and_paper = True
    back_up_seed_phrase_popup.i_am_ready_to_write_down_my_seed_phrase = True
    back_up_seed_phrase_popup.i_know_where_i_ll_store_it = True
    back_up_seed_phrase_popup.confirm_seed_phrase()
    back_up_seed_phrase_popup.reveal_seed_phrase()
    seed_phrases = back_up_seed_phrase_popup.get_seed_phrases()
    back_up_seed_phrase_popup.confirm_seed_phrase()
    back_up_seed_phrase_popup.confirm_first_word(seed_phrases)
    back_up_seed_phrase_popup.continue_confirmation()
    back_up_seed_phrase_popup.confirm_second_word(seed_phrases)
    back_up_seed_phrase_popup.continue_confirmation()
    back_up_seed_phrase_popup.i_acknowledge = True
    back_up_seed_phrase_popup.complete()
    assert driver.waitFor(
        lambda: not main_screen.is_secure_phrase_banner_visible(), driver.settings.UI_LOAD_TIMEOUT_MSEC)


# Test Case: https://ethstatus.testrail.net/index.php?/cases/view/703011
@pytest.mark.case(703011)
@pytest.mark.parametrize('chat_key, who_you_are', [
    pytest.param('zQ3shQihZMmciZWUrjvsY6kUoaqSKp9DFSjMPRkkKGty3XCKZ', 'I am a fellow tester', id='new_contact')
])
def test_add_contact_with_chat_key(main_screen, chat_key, who_you_are):
    settings = main_screen.navigator.open_settings()
    contact_settings = settings.menu_panel.open_messaging_settings().open_contacts_settings()
    contact_settings.add_contact_by_chat_key(chat_key, who_you_are)
    assert chat_key in contact_settings.pending_requests


# Test Case: https://ethstatus.testrail.net/index.php?/cases/view/703009
@pytest.mark.case(703009)
# Each language run takes 30 seconds, so only some of them are enabled until we can parallelize executions
@pytest.mark.parametrize('language, native', [
    # ('English', 'English'),
    pytest.param('Arabic', 'العربية', id='Arabic'),
    # ('Bengali', 'বাংলা'),
    # ('Chinese (China)', '中文（中國)'),
    # ('Chinese (Taiwan)', '中文（台灣)'),
    # ('Dutch', 'Nederlands'),
    # ('French', 'Français'),
    # ('German', 'Deutsch'),
    # ('Hindi', 'हिन्दी'),
    # ('Indonesian', 'Bahasa Indonesia'),
    # ('Italian', 'Italiano'),
    # ('Japanese', '日本語'),
    # ('Korean', '한국어'),
    # ('Malay', 'Bahasa Melayu'),
    # ('Polish', 'Polski'),
    # ('Portuguese', 'Português'),
    # ('Portuguese (Brazil)', 'Português (Brasil)'),
    # ('Russian', 'Русский'),
    # ('Spanish', 'Español'),
    # ('Spanish (Latin America)', 'Español (Latinoamerica)'),
    # ('Spanish (Argentina)', 'Español (Argentina)'),
    # ('Tagalog', 'Tagalog'),
    # ('Turkish', 'Türkçe')
])
def test_search_and_set_language(aut, app_data, language, native):
    aut.launch(f'-d={app_data}')
    main_window = MainWindow().wait_until_appears().prepare()
    if driver.local_system.is_mac():
        AllowNotificationsView().allow()
    BeforeStartedPopUp().get_started()
    main_window.welcome_screen.sign_up()
    SplashScreen().wait_until_appears().wait_until_hidden(driver.settings.APP_LOAD_TIMEOUT_MSEC)
    language_settings = main_window.navigator.open_settings().menu_panel.open_language_settings()
    language_settings.language = language
    ChangeLanguagePopup().close_app()
    aut.detach().stop()

    aut.launch(f'-d={app_data}')
    main_window = MainWindow().wait_until_appears().prepare()
    main_window.welcome_screen.log_in()
    SplashScreen().wait_until_appears().wait_until_hidden(driver.settings.APP_LOAD_TIMEOUT_MSEC)
    language_settings = main_window.navigator.open_settings().menu_panel.open_language_settings()
    assert language_settings.language == native

