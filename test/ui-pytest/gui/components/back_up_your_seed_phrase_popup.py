import typing

from gui.elements import BaseElement, CheckBox, Button, TextEdit


class BackUpYourSeedPhrasePopUp(BaseElement):

    def __init__(self):
        super(BackUpYourSeedPhrasePopUp, self).__init__('o_PopupItem')
        self._i_have_a_pen_and_paper_check_box = CheckBox('i_have_a_pen_and_paper_StatusCheckBox')
        self._i_know_where_i_ll_store_it_check_box = CheckBox('i_know_where_I_ll_store_it_StatusCheckBox')
        self._i_am_ready_to_write_down_seed_phrase_check_box = CheckBox('i_am_ready_to_write_down_StatusCheckBox')
        self._not_now_button = Button('not_Now_StatusButton')
        self._confirm_seed_phrase_button = Button('confirm_Seed_Phrase_StatusButton')
        self._reveal_seed_phrase_button = Button('reveal_seed_phrase_StatusButton')
        self._blur = BaseElement('blur_GaussianBlur')
        self._seed_phrase_panel = BaseElement('confirmSeedPhrasePanel_StatusSeedPhraseInput')
        self._first_word_number = BaseElement('confirmFirstWord')
        self._first_word_text_field = TextEdit('confirmFirstWord_inputText')
        self._continue_button = Button('continue_StatusButton')
        self._second_word_number = BaseElement('confirmSecondWord')
        self._second_word_text_field = TextEdit('confirmSecondWord_inputText')
        self._i_acknowledge_check_box = CheckBox('i_acknowledge_StatusCheckBox')
        self._complete_button = Button('completeAndDeleteSeedPhraseButton')

    @property
    def i_have_a_pen_and_paper(self) -> bool:
        return self._i_have_a_pen_and_paper_check_box.is_checked

    @i_have_a_pen_and_paper.setter
    def i_have_a_pen_and_paper(self, value: bool):
        self._i_have_a_pen_and_paper_check_box.set(value)

    @property
    def i_am_ready_to_write_down_my_seed_phrase(self):
        return self._i_am_ready_to_write_down_seed_phrase_check_box.is_checked

    @i_am_ready_to_write_down_my_seed_phrase.setter
    def i_am_ready_to_write_down_my_seed_phrase(self, value: bool):
        self._i_am_ready_to_write_down_seed_phrase_check_box.set(value)

    @property
    def i_know_where_i_ll_store_it(self):
        return self._i_know_where_i_ll_store_it_check_box.is_checked

    @i_know_where_i_ll_store_it.setter
    def i_know_where_i_ll_store_it(self, value: bool):
        self._i_know_where_i_ll_store_it_check_box.set(value)

    @property
    def i_acknowledge(self):
        return self._i_acknowledge_check_box.is_checked

    @i_acknowledge.setter
    def i_acknowledge(self, value: bool):
        self._i_acknowledge_check_box.set(value)

    def confirm_seed_phrase(self):
        self._confirm_seed_phrase_button.click()

    def reveal_seed_phrase(self):
        self._reveal_seed_phrase_button.click()

    def get_seed_phrases(self):
        phrases = []
        for phrase_n in range(1, 13):
            object_name = f'ConfirmSeedPhrasePanel_StatusSeedPhraseInput_{phrase_n}'
            self._seed_phrase_panel.real_name['objectName'] = object_name
            phrases.append(str(self._seed_phrase_panel.object.textEdit.input.edit.text))
        return phrases

    def confirm_first_word(self, seed_phrases: typing.List[str]):
        first_seed_word = seed_phrases[self._first_word_number.object.wordRandomNumber]
        self._first_word_text_field.clear().text = first_seed_word

    def continue_confirmation(self):
        self._continue_button.click()

    def confirm_second_word(self, seed_phrases: typing.List[str]):
        second_seed_word = seed_phrases[self._second_word_number.object.wordRandomNumber]
        self._second_word_text_field.clear().text = second_seed_word

    def complete(self):
        self._complete_button.click()
        self.wait_until_hidden()
