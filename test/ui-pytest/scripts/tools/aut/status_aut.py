from gui.main_window import MainWindow
from scripts.tools.aut.executable_aut import ExecutableAut


class StatusAut(ExecutableAut):

    def start(self):
        super(StatusAut, self).start()
        return MainWindow().wait_until_appears().prepare()
