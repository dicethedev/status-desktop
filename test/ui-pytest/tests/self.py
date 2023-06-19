from constants.user import user_account_one
from gui.screens.onboarding import LoginView


def test_parallel_execution_one(main_window):
    if LoginView().is_visible:
        main_window.log_in_user(user_account_one)
    else:
        main_window.sign_up_user(user_account_one)


def test_parallel_execution_two(main_window):
    if LoginView().is_visible:
        main_window.log_in_user(user_account_one)
    else:
        main_window.sign_up_user(user_account_one)


def test_parallel_execution_three(main_window):
    if LoginView().is_visible:
        main_window.log_in_user(user_account_one)
    else:
        main_window.sign_up_user(user_account_one)


def test_parallel_execution_five(main_window):
    if LoginView().is_visible:
        main_window.log_in_user(user_account_one)
    else:
        main_window.sign_up_user(user_account_one)