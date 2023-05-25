from gui.elements.base_element import BaseElement
from gui.elements.button import Button
from gui.elements.check_box import CheckBox


class BeforeStartedPopUp(BaseElement):

    def __init__(self):
        super(BeforeStartedPopUp, self).__init__('statusDesktop_mainWindow_overlay')
        self._acknowledge_checkbox = CheckBox('acknowledge_checkbox')
        self._terms_of_use_checkBox = CheckBox('termsOfUseCheckBox_StatusCheckBox')
        self._get_started_button = Button('getStartedStatusButton_StatusButton')

    @property
    def is_visible(self) -> bool:
        return self._get_started_button.is_visible

    def get_started(self):
        self._acknowledge_checkbox.set(True)
        self._terms_of_use_checkBox.set(True, x=10)
        self._get_started_button.click()
        self.wait_until_hidden()
