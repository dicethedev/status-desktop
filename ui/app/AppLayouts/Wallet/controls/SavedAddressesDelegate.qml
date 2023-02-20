import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1
import shared.controls 1.0

import "../popups"
import "../controls"
import ".."

StatusListItem {
    id: root

    property var store
    property var contactsStore
    property string name
    property string address
    property string ens
    property string chainShortNames
    property bool favourite: false
    property var saveAddress: function (name, address, favourite, chainShortNames, ens) {}
    property var deleteSavedAddress: function (address, ens) {}

    signal openSendModal(string recipient)

    implicitWidth: ListView.view.width

    title: name
    objectName: name
    subTitle: {
        if (ens.length > 0)
            return ens
        else
            return WalletUtils.colorizedChainPrefix(chainShortNames) + address
    }
    border.color: Theme.palette.baseColor5
    asset.name: root.favourite ? "star-icon" : "favourite"
    asset.color: root.favourite ? Theme.palette.pinColor1 : (showButtons ? Theme.palette.directColor1 : Theme.palette.baseColor1) // star icon color default
    asset.hoverColor: root.favourite ? "transparent": Theme.palette.directColor1 // star icon color on hover
    asset.bgColor: statusListItemIcon.hovered ? Theme.palette.primaryColor3 : "transparent" // icon outer background color
    asset.bgRadius: 8

    statusListItemIcon.hoverEnabled: true

    onIconClicked: {
        root.saveAddress(root.name, root.address, !root.favourite, root.chainShortNames, root.ens)
    }

    statusListItemSubTitle.font.pixelSize: 13
    statusListItemSubTitle.customColor: !enabled ? Theme.palette.baseColor1 : Theme.palette.directColor1
    statusListItemComponentsSlot.spacing: 0
    property bool showButtons: sensor.containsMouse

    QtObject {
        id: d

        readonly property string visibleAddress: root.address == Constants.zeroAddress ? root.ens : root.address
    }

    components: [
        StatusRoundButton {
            icon.color: root.showButtons ? Theme.palette.directColor1 : Theme.palette.baseColor1
            type: StatusRoundButton.Type.Quinary
            radius: 8
            icon.name: "send"
            onClicked: openSendModal(d.visibleAddress)
        },
        StatusRoundButton {
            objectName: "savedAddressView_Delegate_menuButton"
            visible: !!root.name
            icon.color: root.showButtons ? Theme.palette.directColor1 : Theme.palette.baseColor1
            type: StatusRoundButton.Type.Quinary
            radius: 8
            icon.name: "more"
            onClicked: {
                editDeleteMenu.openMenu(root.name, root.address, root.favourite, root.chainShortNames, root.ens);
            }
        },
        StatusRoundButton {
            visible: !root.name
            icon.color: root.showButtons ? Theme.palette.directColor1 : Theme.palette.baseColor1
            type: StatusRoundButton.Type.Tertiary
            icon.name: "add"
            onClicked: {
                Global.openPopup(addEditSavedAddress,
                                 {
                                     addAddress: true,
                                     address: d.visibleAddress,
                                     ens: root.ens
                                 })
            }
        }
    ]

    StatusMenu {
        id: editDeleteMenu
        property string contactName
        property string contactAddress
        property bool storeFavourite
        property string contactChainShortNames
        property string contactEns
        function openMenu(name, address, favourite, chainShortNames, ens) {
            contactName = name;
            contactAddress = address;
            storeFavourite = favourite;
            contactChainShortNames = chainShortNames;
            contactEns = ens;
            popup();
        }
        onClosed: {
            contactName = "";
            contactAddress = "";
            storeFavourite = false;
            contactChainShortNames = ""
            contactEns = ""
        }
        StatusAction {
            text: qsTr("Edit")
            objectName: "editroot"
            assetSettings.name: "pencil-outline"
            onTriggered: {
                Global.openPopup(addEditSavedAddress,
                                 {
                                     edit: true,
                                     address: editDeleteMenu.contactAddress,
                                     name: editDeleteMenu.contactName,
                                     favourite: editDeleteMenu.storeFavourite,
                                     chainShortNames: editDeleteMenu.contactChainShortNames,
                                     ens: editDeleteMenu.contactEns
                                 })
            }
        }
        StatusAction {
            text: qsTr("Copy")
            objectName: "copySavedAddressAction"
            assetSettings.name: "copy"
            onTriggered: {
                if (d.visibleAddress)
                    store.copyToClipboard(d.visibleAddress)
                else
                    store.copyToClipboard(root.ens)
            }
        }
        StatusMenuSeparator { }
        StatusAction {
            text: qsTr("View on Etherscan")
            objectName: "viewOnEtherscanAction"
            assetSettings.name: "external"
            onTriggered: {
                Global.openLink("https://etherscan.io/address/%1".arg(d.visibleAddress ? d.visibleAddress : root.ens))
            }
        }
        StatusMenuSeparator { }
        StatusAction {
            text: qsTr("Delete")
            type: StatusAction.Type.Danger
            assetSettings.name: "delete"
            objectName: "deleteSavedAddress"
            onTriggered: {
                deleteAddressConfirm.name = editDeleteMenu.contactName;
                deleteAddressConfirm.address = editDeleteMenu.contactAddress;
                deleteAddressConfirm.favourite = editDeleteMenu.storeFavourite;
                deleteAddressConfirm.ens = editDeleteMenu.contactEns
                deleteAddressConfirm.open()
            }
        }
    }

    Component {
        id: addEditSavedAddress
        AddEditSavedAddressPopup {
            id: addEditModal
            anchors.centerIn: parent
            onClosed: destroy()
            contactsStore: root.contactsStore
            store: root.store
            onSave: {
                root.saveAddress(name, address, favourite, chainShortNames, ens)
                close()
            }
        }
    }

    StatusModal {
        id: deleteAddressConfirm
        property string address
        property string ens
        property string name
        property bool favourite
        anchors.centerIn: parent
        header.title: qsTr("Are you sure?")
        header.subTitle: name
        contentItem: StatusBaseText {
            anchors.centerIn: parent
            height: contentHeight + topPadding + bottomPadding
            text: qsTr("Are you sure you want to remove '%1' from your saved addresses?").arg(name)
            font.pixelSize: 15
            color: Theme.palette.directColor1
            wrapMode: Text.Wrap
            topPadding: Style.current.padding
            rightPadding: Style.current.padding
            bottomPadding: Style.current.padding
            leftPadding: Style.current.padding
        }
        rightButtons: [
            StatusButton {
                text: qsTr("Cancel")
                onClicked: deleteAddressConfirm.close()
            },
            StatusButton {
                type: StatusBaseButton.Type.Danger
                objectName: "confirmDeleteSavedAddress"
                text: qsTr("Delete")
                onClicked: {
                    root.deleteSavedAddress(deleteAddressConfirm.address, deleteAddressConfirm.ens)
                    deleteAddressConfirm.close()
                }
            }
        ]
    }
}
