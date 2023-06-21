import pytest

from constants.user import user_account_one
from gui.screens.onboarding import LoginView


@pytest.mark.case(703051)
def test_parallel_execution_one(main_window):
    if LoginView().is_visible:
        main_window.log_in_user(user_account_one)
    else:
        main_window.sign_up_user(user_account_one)


@pytest.mark.case(703069)
def test_parallel_execution_two(main_window):
    if LoginView().is_visible:
        main_window.log_in_user(user_account_one)
    else:
        main_window.sign_up_user(user_account_one)


@pytest.mark.case(703073)
def test_parallel_execution_three(main_window):
    if LoginView().is_visible:
        main_window.log_in_user(user_account_one)
    else:
        main_window.sign_up_user(user_account_one)


@pytest.mark.case(703080)
def test_parallel_execution_five(main_window):
    if LoginView().is_visible:
        main_window.log_in_user(user_account_one)
    else:
        main_window.sign_up_user(user_account_one)