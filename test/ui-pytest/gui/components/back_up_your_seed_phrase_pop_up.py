from gui.objects_map import component_names as names
from gui.wrappers.py_button import PyButton
from gui.wrappers.py_element import PyElement


class BackUpYourSeedPhrasePopUp(PyElement):

    def __init__(self):
        super(BackUpYourSeedPhrasePopUp, self).__init__(names.o_PopupItem)
        self._i_have_a_pen_and_paper_check_box = PyCheckBox(names.i_have_a_pen_and_paper_StatusCheckBox)
        self._i_know_where_I_ll_store_it_check_box = PyCheckBox(names.i_know_where_I_ll_store_it_StatusCheckBox)
        self._i_am_ready_to_write_down_my_seed_phrase_check_box = PyChackBox(
            names.i_am_ready_to_write_down_my_seed_phrase_StatusCheckBox)
        self._not_now_button = PyButton(names.not_Now_StatusButton)
        self._confirm_seed_phrase_button = PyButton(names.confirm_Seed_Phrase_StatusButton)
