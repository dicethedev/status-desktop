import pytest

from constants.user import UserAccount


@pytest.mark.parametrize('main_window', [UserAccount('tester123', 'TesTEr16843/!@00')], indirect=True)
def test_create_user(main_window):
    pass
