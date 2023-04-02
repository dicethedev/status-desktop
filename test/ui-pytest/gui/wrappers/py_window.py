import logging

import squish
import toplevelwindow

import configs
from gui.wrappers.py_element import PyElement

_logger = logging.getLogger(__name__)


class PyWindow(PyElement):

    def prepare(self) -> 'PyWindow':
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

        assert squish.waitFor(lambda: _maximize(), configs.squish.UI_LOAD_TIMEOUT_SEC * 1000), 'Maximize failed'
        _logger.info(f'Window is maximized')

    def minimize(self):

        def _minimize() -> bool:
            try:
                toplevelwindow.ToplevelWindow(self.object).minimize()
                return True
            except RuntimeError:
                return False

        assert squish.waitFor(lambda: _minimize(), configs.squish.UI_LOAD_TIMEOUT_SEC * 1000), 'Minimize failed'
        _logger.info(f'Window is minimized')

    def set_focus(self):

        def _set_focus() -> bool:
            try:
                toplevelwindow.ToplevelWindow(self.object).setFocus()
                return True
            except RuntimeError:
                return False

        assert squish.waitFor(lambda: _set_focus(), configs.squish.APP_LOAD_TIMEOUT_SEC * 1000), 'Set focus failed'
        _logger.info(f'Window in focus')

    def on_top_level(self):

        def _on_top() -> bool:
            try:
                toplevelwindow.ToplevelWindow(self.object).setForeground()
                return True
            except RuntimeError:
                return False

        assert squish.waitFor(lambda: _on_top(), configs.squish.UI_LOAD_TIMEOUT_SEC * 1000), 'Set on top failed'
        _logger.info(f'Window moved on top')

    def close(self):
        squish.sendEvent("QCloseEvent", self.object)

    def close_existed(self, timeout_sec: int = 1) -> bool:
        if self.wait_until_appears(timeout_sec):
            self.close()
            return True
        return False
