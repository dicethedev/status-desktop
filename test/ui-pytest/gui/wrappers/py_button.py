import typing

import squish

from gui.wrappers.py_element import PyElement


class PyButton(PyElement):

    def click(
            self,
            x: typing.Union[int, squish.UiTypes.ScreenPoint] = None,
            y: typing.Union[int, squish.UiTypes.ScreenPoint] = None,
            button: squish.MouseButton = None
    ):
        if hasattr(self.object, 'clicked'):
            self.object.clicked()
        else:
            super(PyButton, self).click(x, y, button)
