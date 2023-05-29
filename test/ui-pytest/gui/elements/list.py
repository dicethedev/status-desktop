import typing

from gui.elements.base_element import BaseElement


class List(BaseElement):

    @property
    def items(self):
        return [self.object.itemAtIndex(index) for index in range(self.object.count)]

    def get_values(self, name: str) -> typing.List[str]:
        values = []
        for index in range(self.object.count):
            value = str(getattr(self.object.itemAtIndex(index), name, ''))
            if value:
                values.append(value)
        return values
