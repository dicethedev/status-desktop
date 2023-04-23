# -*- coding: utf-8 -*-

import names


def main():
    startApplication("nim_status_client")
    mouseClick(waitForObject(names.mainWindow_Password_PlaceholderText))
    type(waitForObject(names.mainWindow_loginPasswordInput_StyledTextField), "qwe")
    mouseClick(waitForObject(names.mainWindow_arrow_right_icon_StatusIcon), 15, 18, Qt.LeftButton)
