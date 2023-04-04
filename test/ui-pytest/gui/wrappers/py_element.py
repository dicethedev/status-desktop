import logging
import typing

import object
import squish

import configs
from scripts.tools.squish_api import dump_objects
from scripts.utils.path import Path

_logger = logging.getLogger(__name__)


class PyElement:

    def __init__(self, object_name: typing.Union[str, dict]):
        self.object_name = object_name

    @property
    def object(self):
        return squish.waitForObject(self.object_name, configs.squish.UI_LOAD_TIMEOUT_SEC * 1000)

    @property
    def exists(self) -> bool:
        return object.exists(self.object_name)

    @property
    def bounds(self) -> squish.UiTypes.ScreenRectangle:
        return object.globalBounds(self.object)

    @property
    def center(self) -> squish.UiTypes.ScreenPoint:
        return self.bounds.center()

    @property
    def width(self) -> int:
        return int(self.bounds.width)

    @property
    def height(self) -> int:
        return int(self.bounds.height)

    @property
    def is_checked(self) -> bool:
        return self.object.checked

    @property
    def is_visible(self) -> bool:
        try:
            return self.object.visible
        except LookupError:
            return False

    def wait_until_appears(self, timeout_sec: int = configs.squish.UI_LOAD_TIMEOUT_SEC) -> 'PyElement':
        assert squish.waitFor(lambda: self.exists, timeout_sec * 1000)
        return self

    def wait_until_hidden(self, timeout_sec: int = configs.squish.UI_LOAD_TIMEOUT_SEC):
        assert squish.waitFor(lambda: not self.exists, timeout_sec * 1000)

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

    def hover(
            self,
            x: typing.Union[int, squish.UiTypes.ScreenPoint] = None,
            y: typing.Union[int, squish.UiTypes.ScreenPoint] = None,
    ):
        squish.mouseMove(x or self.center.x, y or self.center.y)

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
