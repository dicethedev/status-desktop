from gui.objects_map import component_names as names
from gui.wrappers.py_button import PyButton
from gui.wrappers.py_check_box import PyCheckBox
from gui.wrappers.py_element import PyElement


class BeforeStartedPopUp(PyElement):

    def __init__(self):
        super(BeforeStartedPopUp, self).__init__(names.statusDesktop_mainWindow_overlay)
        self._acknowledge_checkbox = PyCheckBox(names.acknowledge_checkbox)
        self._terms_of_use_checkBox = PyCheckBox(names.termsOfUseCheckBox_StatusCheckBox)
        self._get_started_button = PyButton(names.getStartedStatusButton_StatusButton)

    @property
    def exists(self) -> bool:
        return self._get_started_button.exists

    def get_started(self):
        self._acknowledge_checkbox.set(True)
        self._terms_of_use_checkBox.set(True, x=10)
        self._get_started_button.click()
        self.wait_until_hidden()
