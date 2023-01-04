import QtQuick 2.13


import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0
import shared.status 1.0
import shared.popups 1.0
import shared.controls 1.0

import "../../stores"
import "../../popups"

Item {
    id: root
    signal goBack

    property WalletStore walletStore
    property var emojiPopup

    Column {
        id: column
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Style.current.padding
        anchors.rightMargin: Style.current.padding

        spacing: Style.current.bigPadding

        Row {
            id: header
            spacing: Style.current.smallPadding
            StatusSmartIdenticon {
                id: accountImage
                objectName: "walletAccountViewAccountImage"
                anchors.verticalCenter: parent.verticalCenter
                asset: StatusAssetSettings {
                    width: isLetterIdenticon ? 40 : 20
                    height: isLetterIdenticon ? 40 : 20
                    color: walletStore.currentAccount.color
                    emoji: walletStore.currentAccount.emoji
                    name: !walletStore.currentAccount.emoji ? "filled-account": ""
                    letterSize: 14
                    isLetterIdenticon: !!walletStore.currentAccount.emoji
                    bgWidth: 40
                    bgHeight: 40
                    bgColor: Theme.palette.primaryColor3
                }
            }
            Column {
                spacing: Style.current.halfPadding
                Row {
                    spacing: Style.current.halfPadding
                    StatusBaseText {
                        objectName: "walletAccountViewAccountName"
                        id: accountName
                        text: walletStore.currentAccount.name
                        font.weight: Font.Bold
                        font.pixelSize: 28
                        color: Theme.palette.directColor1
                    }
                    StatusFlatRoundButton {
                        objectName: "walletAccountViewEditAccountButton"
                        width: 28
                        height: 28
                        anchors.verticalCenter: accountName.verticalCenter
                        type: StatusFlatRoundButton.Type.Tertiary
                        color: "transparent"
                        icon.name: "pencil"
                        onClicked: Global.openPopup(renameAccountModalComponent)
                    }
                }
                StatusAddressPanel {
                    value: walletStore.currentAccount.address

                    font.weight: Font.Normal

                    showFrame: false

                    onDoCopy: (address) => globalUtils.copyToClipboard(address)
                }
            }
        }


        Flow {
            width: parent.width

            spacing: Style.current.halfPadding

            InformationTile {
                id: typeRectangle
                maxWidth: parent.width
                primaryText: qsTr("Type")
                secondaryText: {
                    const walletType = walletStore.currentAccount.walletType
                    if (walletType === "watch") {
                        return qsTr("Watch-Only Account")
                    } else if (walletType === "generated" || walletType === "") {
                        return qsTr("Generated by your Status seed phrase profile")
                    } else {
                        return qsTr("Imported Account")
                    }
                }
            }

            InformationTile {
                maxWidth: parent.width
                primaryText: qsTr("Storage")
                secondaryText: qsTr("On Device")
            }

            InformationTile {
                maxWidth: parent.width
                primaryText: qsTr("Derivation Path")
                secondaryText: walletStore.currentAccount.path
                visible: walletStore.currentAccount.path
            }

            InformationTile {
                maxWidth: parent.width
                visible: walletStore.currentAccount.relatedAccounts.count > 0
                primaryText: qsTr("Related Accounts")
                tagsModel: walletStore.currentAccount.relatedAccounts
                tagsDelegate: StatusListItemTag {
                    bgColor: model.color
                    bgRadius: 6
                    height: 50
                    closeButtonVisible: false
                    asset.emoji: model.emoji
                    asset.emojiSize: Emoji.size.verySmall
                    asset.isLetterIdenticon: true
                    title: model.name
                    titleText.font.pixelSize: 12
                    titleText.color: Theme.palette.indirectColor1
                }
            }
        }

        StatusButton {
            objectName: "deleteAccountButton"
            visible: walletStore.currentAccount.walletType !== ""
            text: qsTr("Remove from your profile")
            type: StatusBaseButton.Type.Danger

            ConfirmationDialog {
                id: confirmationPopup
                confirmButtonObjectName: "confirmDeleteAccountButton"
                header.title: qsTr("Confirm %1 Removal").arg(walletStore.currentAccount.name)
                confirmationText: qsTr("You will not be able to restore viewing access to this account in the future unless you enter this account’s address again.")
                confirmButtonLabel: qsTr("Remove Account")
                onConfirmButtonClicked: {
                    confirmationPopup.close();
                    root.goBack();
                    root.walletStore.deleteAccount(walletStore.currentAccount.keyUid, walletStore.currentAccount.address);
                }

            }

            onClicked : {
                confirmationPopup.open()
            }
        }
    }

    Component {
        id: renameAccountModalComponent
        RenameAccontModal {
            anchors.centerIn: parent
            onClosed: destroy()
            walletStore: root.walletStore
            emojiPopup: root.emojiPopup
        }
    }
}
