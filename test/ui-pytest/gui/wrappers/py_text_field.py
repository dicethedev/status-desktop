import sys

import squish

import configs.squish
from gui.wrappers.py_element import PyElement


class PyTextField(PyElement):

    @property
    def text(self) -> str:
        return str(self.object.text)

    @text.setter
    def text(self, value: str):
        squish.type(self.object, value)

    def clear(self):
        if self.text:
            self.object.click()
            if sys.platform == "darwin":
                squish.nativeType("<Command+a>")
            else:
                squish.nativeType("<Ctrl+a>")
            squish.type(self.object, '<Backspace>')

        assert squish.waitFor(lambda: not self.text, configs.squish.UI_LOAD_TIMEOUT_SEC), \
            f'Field did not clear, value in field: "{self.text}"'
        return self
