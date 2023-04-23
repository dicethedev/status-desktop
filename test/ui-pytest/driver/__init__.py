import squishtest

from . import aut
from . import config
from . import context
from . import local_system
from . import objects_access
from . import remote_system
from . import server
from . import system_path
from . import toplevel_window
from . import verify

imports = {module.__name__: module for module in [
    aut,
    config,
    context,
    local_system,
    objects_access,
    remote_system,
    server,
    system_path,
    toplevel_window,
    verify
]}


def __getattr__(name):
    if name in imports:
        return imports[name]
    return getattr(squishtest, name)


squishtest.testSettings.waitForObjectTimeout = config.UI_LOAD_TIMEOUT_MSEC
squishtest.setHookSubprocesses(True)
