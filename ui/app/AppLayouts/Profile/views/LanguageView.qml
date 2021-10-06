import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import "../popups"

Item {
    id: languageContainer
    Layout.fillHeight: true
    Layout.fillWidth: true
    clip: true

    property var store
    property Component languagePopup: LanguageModal {
        store: languageContainer.store
    }

    Item {
        anchors.top: parent.top
        anchors.topMargin: 64
        anchors.bottom: parent.bottom
        width: profileContainer.profileContentWidth

        anchors.horizontalCenter: parent.horizontalCenter

        Column {
            id: generalColumn
            width: parent.width

            StatusListItem {
                //% "Language"
                title: qsTrId("language")
                label: globalSettings.locale === "" ? qsTrId("default") : globalSettings.locale
                components: [
                    StatusIcon {
                        icon: "chevron-down"
                        rotation: 270
                        color: Theme.palette.baseColor1
                    }
                ]
                sensor.onClicked: languagePopup.createObject(languageContainer).open()
            }
        }
    }
}
