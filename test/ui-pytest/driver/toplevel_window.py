import squish
import toplevelwindow

from . import config


def maximize(object_name):
    def _maximize() -> bool:
        try:
            toplevelwindow.ToplevelWindow(squish.waitForObject(object_name)).maximize()
            return True
        except RuntimeError:
            return False

    return squish.waitFor(lambda: _maximize(), config.UI_LOAD_TIMEOUT_MSEC)


def minimize(object_name):
    def _minimize() -> bool:
        try:
            toplevelwindow.ToplevelWindow(squish.waitForObject(object_name)).minimize()
            return True
        except RuntimeError:
            return False

    return squish.waitFor(lambda: _minimize(), config.UI_LOAD_TIMEOUT_MSEC)


def set_focus(object_name):
    def _set_focus() -> bool:
        try:
            toplevelwindow.ToplevelWindow(squish.waitForObject(object_name)).setFocus()
            return True
        except RuntimeError:
            return False

    return squish.waitFor(lambda: _set_focus(), config.UI_LOAD_TIMEOUT_MSEC)


def on_top_level(object_name):
    def _on_top() -> bool:
        try:
            toplevelwindow.ToplevelWindow(squish.waitForObject(object_name)).setForeground()
            return True
        except RuntimeError:
            return False

    return squish.waitFor(lambda: _on_top(), config.UI_LOAD_TIMEOUT_MSEC)


def close(object_name):
    squish.sendEvent("QCloseEvent", squish.waitForObject(object_name))
