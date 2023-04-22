import typing

import squish

from gui.elements.base_element import BaseElement


class Button(BaseElement):

    def click(
            self,
            x: typing.Union[int, squish.UiTypes.ScreenPoint] = None,
            y: typing.Union[int, squish.UiTypes.ScreenPoint] = None,
            button: squish.MouseButton = None
    ):
        if None not in (x, y, button):
            self.object.clicked()
        else:
            super(Button, self).click(x, y, button)
