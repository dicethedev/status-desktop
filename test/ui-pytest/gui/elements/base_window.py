import logging

import squish
import toplevelwindow

import configs
from gui.elements.base_element import BaseElement

_logger = logging.getLogger(__name__)


class Window(BaseElement):

    def prepare(self) -> 'Window':
        self.maximize()
        self.on_top_level()
        return self

    def maximize(self):

        def _maximize() -> bool:
            try:
                toplevelwindow.ToplevelWindow(self.object).maximize()
                return True
            except RuntimeError:
                return False

        assert squish.waitFor(lambda: _maximize(), configs.squish.UI_LOAD_TIMEOUT_MSEC * 1000), 'Maximize failed'
        _logger.info(f'Window {getattr(self.object, "title", "")} is maximized')

    def minimize(self):

        def _minimize() -> bool:
            try:
                toplevelwindow.ToplevelWindow(self.object).minimize()
                return True
            except RuntimeError:
                return False

        assert squish.waitFor(lambda: _minimize(), configs.squish.UI_LOAD_TIMEOUT_MSEC * 1000), 'Minimize failed'
        _logger.info(f'Window {getattr(self.object, "title", "")} is minimized')

    def set_focus(self):

        def _set_focus() -> bool:
            try:
                toplevelwindow.ToplevelWindow(self.object).setFocus()
                return True
            except RuntimeError:
                return False

        assert squish.waitFor(lambda: _set_focus(), configs.squish.APP_LOAD_TIMEOUT_MSEC * 1000), 'Set focus failed'
        _logger.info(f'Window {getattr(self.object, "title", "")} in focus')

    def on_top_level(self):

        def _on_top() -> bool:
            try:
                toplevelwindow.ToplevelWindow(self.object).setForeground()
                return True
            except RuntimeError:
                return False

        assert squish.waitFor(lambda: _on_top(), configs.squish.UI_LOAD_TIMEOUT_MSEC * 1000), 'Set on top failed'
        _logger.info(f'Window {getattr(self.object, "title", "")} moved on top')

    def close(self):
        squish.sendEvent("QCloseEvent", self.object)

    def close_existed(self) -> bool:
        if self.existent:
            self.close()
            return True
        return False
