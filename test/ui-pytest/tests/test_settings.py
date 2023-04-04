import pytest
import squish

import configs.squish
from constants.user import UserAccount
from gui.main_window import MainWindow
from gui.screens.settings import SettingsScreen


# Test Case: https://ethstatus.testrail.net/index.php?/cases/view/123
@pytest.mark.case(123)
@pytest.mark.parametrize('main_window', [UserAccount('tester123', 'TesTEr16843/!@00')], indirect=True)
def test_backup_seed_phrase(main_window: MainWindow):
    assert main_window.is_secure_phrase_banner_visible()
    settings: SettingsScreen = main_window.navigator.open_settings()
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
    assert squish.waitFor(lambda: not main_window.is_secure_phrase_banner_visible(),
                          configs.squish.UI_LOAD_TIMEOUT_SEC * 1000)
