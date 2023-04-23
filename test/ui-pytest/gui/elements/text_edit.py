import driver
from gui.elements import BaseElement


class TextEdit(BaseElement):

    @property
    def text(self) -> str:
        return str(self.object.text)

    @text.setter
    def text(self, value: str):
        self.clear()
        self.type_text(value)
        assert driver.waitFor(lambda: self.text == value)

    def type_text(self, value: str):
        driver.type(self.object, value)
        assert driver.waitFor(lambda: self.text == value), \
            f'Type text failed, value in field: "{self.text}", expected: {value}'
        return self

    def clear(self):
        self.object.clear()
        assert driver.waitFor(lambda: not self.text), \
            f'Clear text field failed, value in field: "{self.text}"'
        return self
