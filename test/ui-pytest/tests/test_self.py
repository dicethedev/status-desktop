import pytest

from constants.user import UserAccount
from gui.main_window import MainWindow
from gui.screens.settings import SettingsScreen


@pytest.mark.parametrize('main_window', [UserAccount('tester123', 'TesTEr16843/!@00')], indirect=True)
def test_create_user(main_window: MainWindow):
    settings: SettingsScreen = main_window.navigator.open_settings()
    settings.menu_panel.back_up_seed_phrase()
    pass

