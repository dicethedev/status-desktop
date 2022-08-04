﻿import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import "../../layouts"

import utils 1.0

StackLayout {
    id: root

    property string communityId
    property string name
    property string description
    property string introMessage
    property string outroMessage
    property string logoImageData
    property string bannerImageData
    property rect bannerCropRect
    property color color
    property string tags
    property string selectedTags
    property bool archiveSupportEnabled
    property bool requestToJoinEnabled
    property bool pinMessagesEnabled

    property bool archiveSupportOptionVisible: false
    property bool editable: false
    property bool owned: false

    signal edited(Item item) // item containing edited fields (name, description, logoImagePath, color, options, etc..)

    signal inviteNewPeopleClicked
    signal airdropTokensClicked
    signal backUpClicked

    clip: true

    SettingsPageLayout {
        title: qsTr("Overview")

        content: ColumnLayout {
            spacing: 16

            RowLayout {
                Layout.fillWidth: true

                spacing: 16

                StatusSmartIdenticon {
                    name: root.name

                    icon {
                        width: 80
                        height: 80
                        isLetterIdenticon: !root.logoImageData
                        color: root.color
                        letterSize: width / 2.4
                    }

                    image {
                        width: 80
                        height: 80
                        source: root.logoImageData
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true

                    StatusBaseText {
                        id: nameText
                        Layout.fillWidth: true
                        font.pixelSize: 24
                        color: Theme.palette.directColor1
                        wrapMode: Text.WordWrap
                        text: root.name
                    }

                    StatusBaseText {
                        id: descriptionText
                        Layout.fillWidth: true
                        font.pixelSize: 15
                        color: Theme.palette.directColor1
                        wrapMode: Text.WordWrap
                        text: root.description
                    }
                }

                StatusButton {
                    visible: root.editable
                    text: qsTr("Edit Community")
                    onClicked: root.currentIndex = 1
                }
            }

            Rectangle {
                Layout.fillWidth: true

                implicitHeight: 1
                visible: root.editable
                color: Theme.palette.statusPopupMenu.separatorColor
            }

            RowLayout {
                Layout.fillWidth: true

                visible: root.owned

                StatusIcon {
                    icon: "info"
                }

                StatusBaseText {
                    Layout.fillWidth: true
                    text: qsTr("This node is the Community Owner Node. For your Community to function correctly try to keep this computer with Status running and onlinie as much as possible.")
                    font.pixelSize: 15
                    color: Theme.palette.directColor1
                    wrapMode: Text.WordWrap
                }
            }

            Item {
                Layout.fillHeight: true
            }

            RowLayout {
                CommunityBanner {
                    text: qsTr("Welcome to your community!")
                    buttonText: qsTr("Invite new people")
                    icon.name: "invite-users"
                    onButtonClicked: root.inviteNewPeopleClicked()
                }
                Item {
                   Layout.fillWidth: true
                }
                CommunityBanner {
                    text: qsTr("Try an airdrop to reward your community for engagement!")
                    buttonText: qsTr("Airdrop Tokens")
                    icon.name: "airdrop"
                    onButtonClicked: root.airdropTokensClicked()
                }

                Item {
                   Layout.fillWidth: true
                }

                CommunityBanner {
                    text: qsTr("Back up community key")
                    buttonText: qsTr("Back up")
                    icon.name: "objects"
                    onButtonClicked: root.backUpClicked()
                }
            }
        }
    }

    SettingsPageLayout {
        id: editCommunityPage

        previousPage: qsTr("Overview")
        title: qsTr("Edit Community")
        editable: true

        content: CommunityEditSettingsPanel {
            name: root.name
            description: root.description
            introMessage: root.introMessage
            outroMessage: root.outroMessage
            tags: root.tags
            selectedTags: root.selectedTags
            color: root.color
            logoImageData: root.logoImageData
            bannerImageData: root.bannerImageData
            options {
                archiveSupportOptionVisible: root.archiveSupportOptionVisible
                archiveSupportEnabled: root.archiveSupportEnabled
                requestToJoinEnabled: root.requestToJoinEnabled
                pinMessagesEnabled: root.pinMessagesEnabled
            }

            bottomReservedSpace: editCommunityPage.settingsDirtyToastMessageImplicitSize
            bottomReservedSpaceActive: editCommunityPage.dirty

            Component.onCompleted: {
                editCommunityPage.dirty =
                        Qt.binding(() => {
                                       return root.name != name ||
                                              root.description != description ||
                                              root.introMessage != introMessage ||
                                              root.outroMessage != outroMessage ||
                                              root.archiveSupportEnabled != options.archiveSupportEnabled ||
                                              root.requestToJoinEnabled != options.requestToJoinEnabled ||
                                              root.pinMessagesEnabled != options.pinMessagesEnabled ||
                                              root.color != color ||
                                              root.selectedTags != selectedTags ||
                                              logoImagePath.length > 0 ||
                                              isValidRect(logoCropRect) ||
                                              bannerPath.length > 0 ||
                                              isValidRect(bannerCropRect)
                                   })
                function isValidRect(r /*rect*/) { return r.width !== 0 && r.height !== 0 }
            }
        }

        onPreviousPageClicked: {
            if (dirty) {
                notifyDirty()
            } else {
                root.currentIndex = 0
            }
        }

        onSaveChangesClicked: {
            root.currentIndex = 0
            root.edited(contentItem)
            reloadContent()
        }

        onResetChangesClicked: reloadContent()
    }
}
