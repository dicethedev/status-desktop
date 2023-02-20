import QtQuick 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.14
import QtQuick.Window 2.12

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import shared.controls 1.0
import utils 1.0
import shared.stores 1.0

import "../controls"
import "../stores" as WalletStores
import ".."

Item {
    id: root

    property var currentAccount: RootStore.currentAccount
    property var contactsStore
    property var transaction
    property var sendModal
    readonly property bool isTransactionValid: transaction !== undefined && !!transaction

    QtObject {
        id: d
        readonly property bool isIncoming: root.isTransactionValid ? root.transaction.to === currentAccount.address : false
        readonly property string savedAddressNameTo: root.isTransactionValid ? d.getNameForSavedWalletAddress(transaction.to) : ""
        readonly property string savedAddressNameFrom: root.isTransactionValid ? d.getNameForSavedWalletAddress(transaction.from): ""
        readonly property string from: root.isTransactionValid ? !!savedAddressNameFrom ? savedAddressNameFrom : Utils.compactAddress(transaction.from, 4): ""
        readonly property string to: root.isTransactionValid ? !!savedAddressNameTo ? savedAddressNameTo : Utils.compactAddress(transaction.to, 4): ""
        readonly property string savedAddressEns: RootStore.getEnsForSavedWalletAddress(isIncoming ? transaction.from : transaction.to)
        readonly property string savedAddressChains: RootStore.getChainShortNamesForSavedWalletAddress(isIncoming ? transaction.from : transaction.to)

        function getNameForSavedWalletAddress(address) {
            return RootStore.getNameForSavedWalletAddress(address)
        }
    }


    StatusScrollView {
        anchors.top: parent.top
        anchors.left: parent.left

        width: parent.width
        height: parent.height
        contentHeight: column.height
        contentWidth: parent.width

        Column {
            id: column
            width: parent.width - Style.current.xlPadding

            spacing: Style.current.bigPadding

            TransactionDelegate {
                objectName: "transactionDetailHeader"
                width: parent.width

                modelData: transaction
                isIncoming: d.isIncoming
                currentCurrency: RootStore.currentCurrency
                cryptoValue: root.isTransactionValid ? transaction.value.amount: 0.0
                fiatValue: root.isTransactionValid ? RootStore.getFiatValue(cryptoValue, symbol, currentCurrency): 0.0
                networkIcon: root.isTransactionValid ? RootStore.getNetworkIcon(transaction.chainId): ""
                networkColor: root.isTransactionValid ? RootStore.getNetworkColor(transaction.chainId): ""
                networkName: root.isTransactionValid ? RootStore.getNetworkShortName(transaction.chainId): ""
                symbol: root.isTransactionValid ? transaction.symbol : ""
                transferStatus: root.isTransactionValid ? RootStore.hex2Dec(transaction.txStatus): ""
                shortTimeStamp: root.isTransactionValid ? LocaleUtils.formatTime(transaction.timestamp * 1000, Locale.ShortFormat): ""
                savedAddressName: root.isTransactionValid ? RootStore.getNameForSavedWalletAddress(transaction.to): ""
                title: d.isIncoming ? qsTr("Received %1 from %2").arg(RootStore.formatCurrencyAmount(cryptoValue, symbol)).arg(d.from) :
                                    qsTr("Sent %1 to %2").arg(RootStore.formatCurrencyAmount(cryptoValue, symbol)).arg(d.to)
                sensor.enabled: false
                color: Theme.palette.statusListItem.backgroundColor
                state: "big"
            }

            SavedAddressesDelegate {
                width: parent.width

                name: d.isIncoming ? d.savedAddressNameFrom : d.savedAddressNameTo
                address:  root.isTransactionValid ? d.isIncoming ? transaction.from : transaction.to : ""
                ens: d.savedAddressEns
                chainShortNames: d.savedAddressChains
                title: d.isIncoming ? d.from : d.to
                subTitle:  root.isTransactionValid ? d.isIncoming ? !!d.savedAddressNameFrom ? Utils.compactAddress(transaction.from, 4) : "" : !!d.savedAddressNameTo ? Utils.compactAddress(transaction.to, 4) : "": ""
                store: WalletStores.RootStore
                contactsStore: root.contactsStore
                onOpenSendModal: root.sendModal.open(address);
                saveAddress: function(name, address, favourite, chainShortNames, ens) {
                    RootStore.createOrUpdateSavedAddress(name, address, favourite, chainShortNames, ens)
                }
                deleteSavedAddress: function(address, ens) {
                    RootStore.deleteSavedAddress(address, ens)
                }
            }

            StatusExpandableItem {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter

                type: StatusExpandableItem.Type.Tertiary
                expandable: true
                primaryText: qsTr("Transaction summary")
                expandableComponent: transactionSummary
                separatorVisible: false
                expanded: true
            }

            StatusExpandableItem {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter

                type: StatusExpandableItem.Type.Tertiary
                expandable: true
                primaryText: qsTr("Fees")
                expandableComponent: fees
                expanded: true
            }

            InformationTile {
                maxWidth: parent.width
                primaryText: qsTr("Data")
                secondaryText: root.isTransactionValid ? root.transaction.input : ""
                copy: true
                onCopyClicked: RootStore.copyToClipboard(textToCopy)
            }
        }
    }


    Component {
        id: transactionSummary
        Column {
            id: column
            width: parent.width
            spacing: 8
            TransactionDelegate {
                width: parent.width
                modelData: transaction
                isIncoming: d.isIncoming
                currentCurrency: RootStore.currentCurrency
                cryptoValue: root.isTransactionValid ? transaction.value.amount: 0.0
                fiatValue: root.isTransactionValid ? RootStore.getFiatValue(cryptoValue, symbol, currentCurrency): 0.0
                networkIcon: root.isTransactionValid ? RootStore.getNetworkIcon(transaction.chainId) : ""
                networkColor: root.isTransactionValid ? RootStore.getNetworkColor(transaction.chainId): ""
                networkName: root.isTransactionValid ? RootStore.getNetworkShortName(transaction.chainId): ""
                symbol: root.isTransactionValid ? transaction.symbol : ""
                transferStatus: root.isTransactionValid ? RootStore.hex2Dec(transaction.txStatus): ""
                shortTimeStamp: root.isTransactionValid ? LocaleUtils.formatTime(transaction.timestamp * 1000, Locale.ShortFormat): ""
                savedAddressName: root.isTransactionValid ? RootStore.getNameForSavedWalletAddress(transaction.to): ""
                title: d.isIncoming ? qsTr("Received %1 from %2").arg(RootStore.formatCurrencyAmount(cryptoValue, symbol)).arg(d.from) :
                                    qsTr("Sent %1 to %2").arg(RootStore.formatCurrencyAmount(cryptoValue, symbol)).arg(d.to)
                sensor.enabled: false
                color: Theme.palette.statusListItem.backgroundColor
                border.width: 1
                border.color: Theme.palette.directColor8
            }
            Row {
                spacing: 8
                InformationTile {
                    maxWidth: parent.width
                    primaryText: qsTr("Time")
                    secondaryText:  root.transaction !== undefined && !!root.transaction ? qsTr("%1 <font color=\"#939BA1\">on</font> %2").
                                                                     arg(LocaleUtils.formatTime(transaction.timestamp * 1000, Locale.ShortFormat)).
                                                                     arg(LocaleUtils.formatDate(transaction.timestamp * 1000, Locale.ShortFormat)): ""
                }
                InformationTile {
                    maxWidth: parent.width
                    primaryText: qsTr("Confirmations")
                    secondaryText: {
                        if(root.isTransactionValid)
                            return Math.abs(RootStore.getLatestBlockNumber() - RootStore.hex2Dec(root.transaction.blockNumber))
                        else
                            return ""
                    }
                }
                InformationTile {
                    maxWidth: parent.width
                    primaryText: qsTr("Nonce")
                    secondaryText: root.isTransactionValid ? RootStore.hex2Dec(root.transaction.nonce) : ""
                }
            }
        }
    }

    Component {
        id: fees
        Column {
            width: parent.width
            spacing: 8
            Row {
                spacing: 8
                InformationTile {
                    id: baseFee
                    maxWidth: parent.width
                    primaryText: qsTr("Base fee")
                    secondaryText: root.isTransactionValid ?  qsTr("%1").arg(LocaleUtils.currencyAmountToLocaleString(root.transaction.baseGasFees)) : ""
                }
                InformationTile {
                    maxWidth: parent.width
                    primaryText: qsTr("Tip")
                    secondaryText: root.isTransactionValid ?    "%1 <font color=\"%2\">&#8226; ".
                                                                    arg(LocaleUtils.currencyAmountToLocaleString(root.transaction.maxPriorityFeePerGas)).
                                                                    arg(Theme.palette.baseColor1) +
                                                                qsTr("Max: %1").
                                                                    arg(LocaleUtils.currencyAmountToLocaleString(root.transaction.maxFeePerGas)) +
                                                                "</font>" : ""
                    secondaryLabel.textFormat: Text.RichText
                }
            }
            InformationTile {
                maxWidth: parent.width
                primaryText: qsTr("Total fee")
                secondaryText: root.isTransactionValid ?    "%1 <font color=\"%2\">&#8226; ".
                                                                arg(LocaleUtils.currencyAmountToLocaleString(root.transaction.totalFees)).
                                                                arg(Theme.palette.baseColor1) +
                                                            qsTr("Max: %1").
                                                                arg(LocaleUtils.currencyAmountToLocaleString(root.transaction.maxTotalFees)) +
                                                            "</font>" : ""
                secondaryLabel.textFormat: Text.RichText
            }
        }
    }
}
