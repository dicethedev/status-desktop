import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.13

import StatusQ.Popups 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared.controls 1.0

import "../popups"
import "../controls"

Rectangle {
    id: walletFooter

    property var sendModal
    property var walletStore
    property var networkConnectionStore

    height: 61
    color: Theme.palette.statusAppLayout.rightPanelBackgroundColor

    StatusModalDivider {
        anchors.top: parent.top
        width: parent.width
    }

    RowLayout {
        anchors.centerIn: parent
        height: parent.height
        spacing:  Style.current.padding

        DisabledTooltipButton {
            buttonType: DisabledTooltipButton.Flat
            aliasedObjectName: "walletFooterSendButton"
            icon: "send"
            text: qsTr("Send")
            interactive: networkConnectionStore.sendBuyBridgeEnabled
            onClicked: function() {
                sendModal.open()
            }
            tooltipText: networkConnectionStore.sendBuyBridgeToolTipText
        }

        StatusFlatButton {
            icon.name: "receive"
            text: qsTr("Receive")
            onClicked: function () {
                Global.openPopup(receiveModalComponent);
            }
        }

        DisabledTooltipButton {
            icon: "bridge"
            buttonType: DisabledTooltipButton.Flat
            text: qsTr("Bridge")
            interactive: networkConnectionStore.sendBuyBridgeEnabled
            onClicked: function() {
                sendModal.isBridgeTx = true
                sendModal.open()
            }
            tooltipText: networkConnectionStore.sendBuyBridgeToolTipText
        }
        
        StatusFlatButton {
            id: buySellBtn
            icon.name: "token"
            text: qsTr("Buy")
            onClicked: function () {
                Global.openPopup(buySellModal);
            }
        }
    }

    Component {
        id: receiveModalComponent
        ReceiveModal {
            anchors.centerIn: parent
        }
    }

    Component {
        id: buySellModal
        CryptoServicesModal {}
    }
}


