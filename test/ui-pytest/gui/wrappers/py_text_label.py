from gui.wrappers.py_element import PyElement


class PyTextLabel(PyElement):

    @property
    def text(self) -> str:
        return str(self.object.text)
