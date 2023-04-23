from gui.elements import BaseElement


class TextLabel(BaseElement):

    @property
    def text(self) -> str:
        return str(self.object.text)
