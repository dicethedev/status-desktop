import time

import allure
import pytest
from allure import step

import configs.timeouts
import constants
import driver
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.main_window import MainWindow

pytestmark = allure.suite("Wallet")


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703021', 'Manage a saved address')
@pytest.mark.case(703021)
@pytest.mark.parametrize('name, address, new_name', [
    pytest.param('Saved address name before', '0x8397bc3c5a60a1883174f722403d63a8833312b7', 'Saved address name after'),
    pytest.param('Ens name before', 'nastya.stateofus.eth', 'Ens name after')
])
def test_manage_saved_address(main_screen: MainWindow, name: str, address: str, new_name: str):
    with step('Add new address'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        wallet.left_panel.open_saved_addresses().open_add_address_popup().add_saved_address(name, address)

    with step('Verify that saved address is in the list of saved addresses'):
        assert driver.waitFor(
            lambda: name in wallet.left_panel.open_saved_addresses().address_names,
            configs.timeouts.UI_LOAD_TIMEOUT_MSEC), f'Address: {name} not found'

    with step('Edit saved address to new name'):
        wallet.left_panel.open_saved_addresses().open_edit_address_popup(name).edit_saved_address(new_name, address)

    with step('Verify that saved address with new name is in the list of saved addresses'):
        assert driver.waitFor(
            lambda: new_name in wallet.left_panel.open_saved_addresses().address_names,
            configs.timeouts.UI_LOAD_TIMEOUT_MSEC), f'Address: {new_name} not found'

    with step('Delete address with new name'):
        wallet.left_panel.open_saved_addresses().delete_saved_address(new_name)

    with step('Verify that saved address with new name is not in the list of saved addresses'):
        assert driver.waitFor(
            lambda: new_name not in wallet.left_panel.open_saved_addresses().address_names)

    with step('Verify that saved address is in the list of saved addresses'):
        assert driver.waitFor(
            lambda: name in wallet.open_saved_addresses().address_names,
            configs.timeouts.UI_LOAD_TIMEOUT_MSEC), f'Address: {name} not found'

    with step('Edit saved address to new name'):
        wallet.open_saved_addresses().open_edit_address_popup(name).edit_saved_address(new_name, address)

    with step('Verify that saved address with new name is in the list of saved addresses'):
        assert driver.waitFor(
            lambda: new_name in wallet.open_saved_addresses().address_names,
            configs.timeouts.UI_LOAD_TIMEOUT_MSEC), f'Address: {new_name} not found'

    with step('Delete address with new name'):
        wallet.open_saved_addresses().delete_saved_address(new_name)

    with step('Verify that saved address with new name is not in the list of saved addresses'):
        assert driver.waitFor(
            lambda: new_name not in wallet.open_saved_addresses().address_names,
            configs.timeouts.UI_LOAD_TIMEOUT_MSEC), f'Address: {new_name} not found'


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703025', 'Edit default wallet account')
@pytest.mark.case(703025)
@pytest.mark.parametrize('name, new_name, new_color, new_emoji, new_emoji_unicode', [
    pytest.param('Status account', 'MyPrimaryAccount', '#216266', 'sunglasses', '1f60e')
])
def test_edit_default_wallet_account(main_screen: MainWindow, name: str, new_name: str, new_color: str, new_emoji: str, new_emoji_unicode: str):
    with step('Select wallet account'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        wallet.select_account(name)

    with step('Edit wallet account'):
        account_popup = wallet.open_edit_account_popup(name)
        account_popup.set_name(new_name)
        account_popup.set_emoji(new_emoji)
        account_popup.set_color(new_color)
        account_popup.save()

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(new_name, new_color.lower(), new_emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.accounts}')
