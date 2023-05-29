import time
import typing

import driver.settings
from gui.elements.base_element import BaseElement


class List(BaseElement):

    @property
    def items(self):
        return [self.object.itemAtIndex(index) for index in range(self.object.count)]

    def get_values(self, attr_name: str) -> typing.List[str]:
        values = []
        for index in range(self.object.count):
            value = str(getattr(self.object.itemAtIndex(index), attr_name, ''))
            if value:
                values.append(value)
        return values

    def select(self, value: str, attr_name: str):
        driver.mouseClick(self.wait_for_item(value, attr_name))

    def wait_for_item(self, value: str, attr_name: str, timeout_sec: int = driver.settings.PROCESS_TIMEOUT_SEC):
        started_at = time.monotonic()
        values = []
        while True:
            for index in range(self.object.count):
                cur_value = str(getattr(self.object.itemAtIndex(index), attr_name, ''))
                if cur_value == value:
                    return self.object.itemAtIndex(index)
                values.append(cur_value)
            time.sleep(1)
            if time.monotonic() - started_at > timeout_sec:
                raise RuntimeError(f'value not found in list: {values}')




