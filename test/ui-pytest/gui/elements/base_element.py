import logging
import time
import typing

import object
import squish

import configs.squish
from gui import objects_map
from scripts.tools.squish_api import context, dump_objects
from scripts.utils.path import Path

_logger = logging.getLogger(__name__)


class BaseElement:

    def __init__(self, symbolic_name: str):
        self.symbolic_name = symbolic_name
        self.real_name = getattr(objects_map, symbolic_name)

    def __str__(self):
        return f'{type(self).__qualname__}({self.symbolic_name})'

    @staticmethod
    def detach():
        context.detach()

    @property
    def object(self):
        return squish.waitForObject(self.real_name)

    @property
    def existent(self):
        return squish.waitForObjectExists(self.real_name)

    @property
    def bounds(self) -> squish.UiTypes.ScreenRectangle:
        return object.globalBounds(self.object)

    @property
    def width(self) -> int:
        return int(self.bounds.width)

    @property
    def height(self) -> int:
        return int(self.bounds.height)

    @property
    def center(self) -> squish.UiTypes.ScreenPoint:
        return self.bounds.center()

    @property
    def is_enabled(self) -> bool:
        return self.object.enabled

    @property
    def is_selected(self) -> bool:
        return self.object.selected

    @property
    def is_checked(self) -> bool:
        return self.object.checked

    @property
    def is_visible(self) -> bool:
        try:
            return squish.waitForObject(self.real_name, 500).visible
        except LookupError:
            return False

    def click(
            self,
            x: typing.Union[int, squish.UiTypes.ScreenPoint] = None,
            y: typing.Union[int, squish.UiTypes.ScreenPoint] = None,
            button: squish.MouseButton = None
    ):
        squish.mouseClick(
            self.object,
            x or self.width // 2,
            y or self.height // 2,
            button or squish.MouseButton.LeftButton
        )

    def hover(self, timeout_msec: int = configs.squish.UI_LOAD_TIMEOUT_MSEC):
        def _hover():
            try:
                squish.mouseMove(self.object)
                return getattr(self.object, 'hovered', True)
            except RuntimeError as err:
                _logger.info(err)
                time.sleep(1)
                return False

        assert squish.waitFor(lambda: _hover(), timeout_msec)

    def wait_until_appears(self, timeout_msec: int = configs.squish.UI_LOAD_TIMEOUT_MSEC):
        assert squish.waitFor(lambda: self.is_visible, timeout_msec), f'Object {self} is not visible'
        return self

    def wait_until_hidden(self, timeout_msec: int = configs.squish.UI_LOAD_TIMEOUT_MSEC):
        assert squish.waitFor(lambda: not self.is_visible, timeout_msec), f'Object {self} is not hidden'

    def wait_for(self, condition, timeout_msec: int = configs.squish.UI_LOAD_TIMEOUT_MSEC) -> bool:
        return squish.waitFor(lambda: condition, timeout_msec)

    def dump_objects(
            self,
            out_file_name: Path = None,
            recursive: bool = True,
            depth: int = 1,
            take_screenshots: bool = True
    ):
        configs.path.TEST_ARTIFACTS.mkdir(parents=True, exist_ok=True)
        out_file_name = str(configs.path.TEST_ARTIFACTS / 'dump.xml') or out_file_name
        dump_objects.dump_objects_to_file(self.object, out_file_name, recursive, depth, take_screenshots)
