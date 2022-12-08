import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import shared.panels 1.0
import shared.popups 1.0

Control {
    id: root

    implicitWidth: 270 // by design
    implicitHeight: !d.invitedCommunity ? 0 : Math.max(implicitBackgroundHeight + topInset + bottomInset,
                                                       implicitContentHeight + verticalPadding)

    padding: 1

    property var store
    property string communityId

    QtObject {
        id: d

        property var invitedCommunity

        readonly property int margin: 12
        readonly property int radius: 16

        function getCommunity() {
            try {
                const communityJson = root.store.getSectionByIdJson(communityId)

                if (!communityJson) {
                    root.store.requestCommunityInfo(communityId)
                    return null
                }

                return JSON.parse(communityJson);
            } catch (e) {
                console.error("Error parsing community", e)
            }

            return null
        }

        function reevaluate() {
            invitedCommunity = getCommunity()
        }
    }

    Component.onCompleted: {
        d.reevaluate()
    }

    Connections {
        target: root.store.communitiesModuleInst
        onCommunityChanged: function (communityId) {
            if (communityId === root.communityId) {
                d.reevaluate()
            }
        }
    }

    Connections {
        target: root.store.communitiesModuleInst
        onCommunityAdded: function (communityId) {
            if (communityId === root.communityId) {
                d.reevaluate()
            }
        }
    }

    background: Rectangle {
        radius: d.radius
        color: Style.current.background
        border.color: Style.current.border
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: 0

        StatusBaseText {
            id: title

            Layout.fillWidth: true
            Layout.leftMargin: d.margin
            Layout.rightMargin: d.margin
            Layout.topMargin: 8
            Layout.bottomMargin: 8

            text: d.invitedCommunity.verifed ? qsTr("Verified community invitation") : qsTr("Community invitation")
            color: d.invitedCommunity.verifed ? Theme.palette.primaryColor1 : Theme.palette.baseColor1
            font.weight: Font.Medium
            font.pixelSize: 13
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Style.current.separator
        }

        RowLayout {
            id: communityDescriptionLayout

            Layout.leftMargin: d.margin
            Layout.rightMargin: d.margin
            Layout.topMargin: 12
            Layout.bottomMargin: 12

            spacing: 12

            StatusSmartIdenticon {
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40

                name: d.invitedCommunity.name

                asset {
                    width: 40
                    height: 40
                    name: d.invitedCommunity.image
                    color: d.invitedCommunity.color
                    isImage: true
                }
            }

            ColumnLayout {
                spacing: 2

                StatusBaseText {
                    Layout.fillWidth: true

                    text: d.invitedCommunity.name
                    font.weight: Font.Bold
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.pixelSize: 17
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    Layout.fillWidth: true

                    text: d.invitedCommunity.description
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    Layout.fillWidth: true

                    text: qsTr("%n member(s)", "", d.invitedCommunity.nbMembers)
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    color: Theme.palette.baseColor1
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Style.current.separator
        }

        StatusFlatButton {
            id: joinBtn

            Layout.fillWidth: true
            Layout.preferredHeight: 44

            text: qsTr("Go to Community")
            radius: d.radius - 1 // We do -1, otherwise there's a gap between border and button

            onClicked: {
                if (d.invitedCommunity.joined || d.invitedCommunity.spectated) {
                    root.store.setActiveCommunity(communityId)
                } else {
                    root.store.spectateCommunity(communityId, userProfile.name)
                }
            }
        }
    }
}
