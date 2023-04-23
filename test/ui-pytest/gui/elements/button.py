import typing

import driver
from gui.elements import BaseElement


class Button(BaseElement):

    def click(
            self,
            x: typing.Union[int, driver.UiTypes.ScreenPoint] = None,
            y: typing.Union[int, driver.UiTypes.ScreenPoint] = None,
            button: driver.MouseButton = None
    ):
        if None not in (x, y, button):
            self.object.clicked()
        else:
            super(Button, self).click(x, y, button)
