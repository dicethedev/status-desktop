import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.1

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Models 0.1
import StatusQ.Internal 0.1

import SortFilterProxyModel 0.2

import utils 1.0

import shared.stores 1.0
import shared.controls 1.0
import shared.popups 1.0

import AppLayouts.Wallet.controls 1.0

ColumnLayout {
    id: root

    // expected roles: name, symbol, balances, currencyPrice, changePct24hour, communityId, communityName, communityImage
    required property var controller

    property var currencyStore
    property var networkConnectionStore
    required property var tokensStore
    property var overview
    property bool assetDetailsLaunched: false
    property bool filterVisible
    property bool areAssetsLoading: false
    property string addressFilters
    property string networkFilters

    signal assetClicked(var token)
    signal sendRequested(string symbol)
    signal receiveRequested(string symbol)
    signal switchToCommunityRequested(string communityId)
    signal manageTokensRequested()

    spacing: 0

    QtObject {
        id: d
        property int selectedAssetIndex: -1
        readonly property int loadingItemsCount: 25

        readonly property bool isCustomView: cmbTokenOrder.currentValue === SortOrderComboBox.TokenOrderCustom

        function tokenIsVisible(symbol, currentCurrencyBalance, isCommunityAsset) {
            // NOTE Backend returns ETH, SNT, STT and DAI by default
            if (!root.controller.filterAcceptsSymbol(symbol)) // explicitely hidden
                return false
            if (isCommunityAsset)
                return true
            // Received tokens can have 0 balance, which indicate previously owned token
            if (root.tokensStore.displayAssetsBelowBalance) {
                const threshold = root.tokensStore.getDisplayAssetsBelowBalanceThresholdDisplayAmount()
                if (threshold > 0)
                    return currentCurrencyBalance > threshold
            }
            return true
        }

        function getTotalBalance(balances, decimals, key) {
            let totalBalance = 0
            let nwFilters = root.networkFilters.split(":")
            let addrFilters = root.addressFilters.split(":")
            for(let i=0; i<balances.count; i++) {
                let balancePerAddressPerChain = ModelUtils.get(balances, i)
                if (nwFilters.includes(balancePerAddressPerChain.chainId+"") &&
                        addrFilters.includes(balancePerAddressPerChain.account)) {
                    totalBalance+=SQUtils.AmountsArithmetic.toNumber(balancePerAddressPerChain[key], decimals)
                }
            }
            return totalBalance
        }

        property SortFilterProxyModel customSFPM: SortFilterProxyModel {
            sourceModel: root.controller.sourceModel
            proxyRoles: [
                FastExpressionRole {
                    name: "currentBalance"
                    expression: d.getTotalBalance(model.balances, model.decimals, "balance")
                    expectedRoles: ["balances", "decimals"]
                },
                FastExpressionRole {
                    name: "currentCurrencyBalance"
                    expression: {
                        if(!model.communityId) {
                            if (!!model.marketDetails) {
                                return model.currentBalance * model.marketDetails.currencyPrice.amount
                            }
                            return 0
                        }
                        return model.currentBalance
                    }
                    expectedRoles: ["marketDetails", "communityId", "currentBalance"]
                },
                FastExpressionRole {
                    name: "tokenPrice"
                    expression: model.marketDetails.currencyPrice.amount
                    expectedRoles: ["marketDetails"]
                },
                FastExpressionRole {
                    name: "change1DayFiat"
                    expression: {
                        if (!model.isCommunityAsset && !!model.marketDetails) {
                            const balance1DayAgo = d.getTotalBalance(model.balances, model.decimals, "balance1DayAgo")
                            const change = (model.currentBalance * model.marketDetails.currencyPrice.amount) - (balance1DayAgo * (model.marketDetails.currencyPrice.amount - model.marketDetails.change24hour))
                            return change
                        }
                        return 0
                    }
                    expectedRoles: ["marketDetails", "balances", "decimals", "currentBalance", "isCommunityAsset"]
                },
                FastExpressionRole {
                    name: "isCommunityAsset"
                    expression: !!model.communityId
                    expectedRoles: ["communityId"]
                }
            ]
            filters: [
                FastExpressionFilter {
                    expression: {
                        root.controller.revision
                        root.tokensStore.displayAssetsBelowBalance
                        return d.tokenIsVisible(model.symbol, model.currentCurrencyBalance, model.isCommunityAsset)
                    }
                    expectedRoles: ["symbol", "currentCurrencyBalance", "isCommunityAsset"]
                }
            ]
            sorters: [
                RoleSorter {
                    roleName: "isCommunityAsset"
                },
                FastExpressionSorter {
                    expression: {
                        root.controller.revision
                        return root.controller.compareTokens(modelLeft.symbol, modelRight.symbol)
                    }
                    enabled: d.isCustomView
                    expectedRoles: ["symbol"]
                },
                RoleSorter {
                    roleName: cmbTokenOrder.currentSortRoleName
                    sortOrder: cmbTokenOrder.currentSortOrder
                    enabled: !d.isCustomView
                }
            ]
        }
    }

    Settings {
        id: settings
        category: "AssetsViewSortSettings"
        property int currentSortValue: SortOrderComboBox.TokenOrderCurrencyBalance
        property alias currentSortOrder: cmbTokenOrder.currentSortOrder
    }

    Component.onCompleted: {
        settings.sync()
        cmbTokenOrder.currentIndex = cmbTokenOrder.indexOfValue(settings.currentSortValue)
    }

    Component.onDestruction: {
        settings.currentSortValue = cmbTokenOrder.currentValue
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: root.filterVisible ? implicitHeight : 0
        spacing: 20
        opacity: root.filterVisible ? 1 : 0
        visible: opacity > 0

        Behavior on Layout.preferredHeight { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

        StatusDialogDivider {
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.current.halfPadding

            StatusBaseText {
                color: Theme.palette.baseColor1
                font.pixelSize: Style.current.additionalTextSize
                text: qsTr("Sort by:")
            }

            SortOrderComboBox {
                id: cmbTokenOrder
                objectName: "cmbTokenOrder"
                hasCustomOrderDefined: root.controller.hasSettings
                model: [
                    { value: SortOrderComboBox.TokenOrderCurrencyBalance, text: qsTr("Asset balance value"), icon: "", sortRoleName: "currentCurrencyBalance" }, // custom SFPM ExpressionRole on "enabledNetworkCurrencyBalance" amount
                    { value: SortOrderComboBox.TokenOrderBalance, text: qsTr("Asset balance"), icon: "", sortRoleName: "currentBalance" }, // custom SFPM ExpressionRole on "enabledNetworkBalance" amount
                    { value: SortOrderComboBox.TokenOrderCurrencyPrice, text: qsTr("Asset value"), icon: "", sortRoleName: "tokenPrice" }, // custom SFPM ExpressionRole on "currencyPrice" amount
                    { value: SortOrderComboBox.TokenOrder1DChange, text: qsTr("1d change: balance value"), icon: "", sortRoleName: "change1DayFiat" }, // custom SFPM ExpressionRole
                    { value: SortOrderComboBox.TokenOrderAlpha, text: qsTr("Asset name"), icon: "", sortRoleName: "name" },
                    { value: SortOrderComboBox.TokenOrderCustom, text: qsTr("Custom order"), icon: "", sortRoleName: "" },
                    { value: SortOrderComboBox.TokenOrderNone, text: "---", icon: "", sortRoleName: "" }, // separator
                    { value: SortOrderComboBox.TokenOrderCreateCustom, text: hasCustomOrderDefined ? qsTr("Edit custom order →") : qsTr("Create custom order →"),
                        icon: "", sortRoleName: "" }
                ]
                onCreateOrEditRequested: {
                    root.manageTokensRequested()
                }
            }
        }

        StatusDialogDivider {
            Layout.fillWidth: true
        }
    }

    StatusListView {
        id: assetsListView
        Layout.fillWidth: true
        Layout.topMargin: Style.current.padding
        Layout.preferredHeight: contentHeight
        Layout.fillHeight: true
        objectName: "assetViewStatusListView"
        model: root.areAssetsLoading ? d.loadingItemsCount : d.customSFPM
        delegate: delegateLoader
        section {
            property: "isCommunityAsset"
            delegate: Loader {
                width: ListView.view.width
                required property string section
                sourceComponent: section === "true" ? sectionDelegate : null
            }
        }
    }

    Component {
        id: sectionDelegate
        AssetsSectionDelegate {
            width: parent.width
            text: qsTr("Community minted")
            onOpenInfoPopup: Global.openPopup(communityInfoPopupCmp)
        }
    }

    Component {
        id: delegateLoader
        Loader {
            property var modelData: model
            property int delegateIndex: index
            width: ListView.view.width
            sourceComponent: root.areAssetsLoading ? loadingTokenDelegate : tokenDelegate
        }
    }

    Component {
        id: loadingTokenDelegate
        LoadingTokenDelegate {
            objectName: "AssetView_LoadingTokenDelegate_" + delegateIndex
        }
    }

    Component {
        id: tokenDelegate
        TokenDelegate {
            objectName: "AssetView_TokenListItem_" + (!!modelData ? modelData.symbol : "")
            readonly property string balance: !!modelData && !!modelData.currentBalance ? "%1".arg(modelData.currentBalance) : "" // Needed for the tests
            errorTooltipText_1: !!modelData && !!networkConnectionStore ? networkConnectionStore.getBlockchainNetworkDownTextForToken(modelData.balances) : ""
            errorTooltipText_2: !!networkConnectionStore ? networkConnectionStore.getMarketNetworkDownText() : ""
            subTitle: {
                if (!modelData || !modelData.symbol) {
                    return ""
                }
                if (networkConnectionStore && networkConnectionStore.noTokenBalanceAvailable) {
                    return ""
                }
                return LocaleUtils.currencyAmountToLocaleString(root.currencyStore.getCurrencyAmount(modelData.currentBalance, modelData.symbol))
            }
            currencyBalance.text: {
                let totalCurrencyBalance = modelData && modelData.currentCurrencyBalance ? modelData.currentCurrencyBalance : 0
                return currencyStore.formatCurrencyAmount(totalCurrencyBalance, currencyStore.currentCurrency)
            }
            errorMode: !!networkConnectionStore ? networkConnectionStore.noBlockchainConnectionAndNoCache && !networkConnectionStore.noMarketConnectionAndNoCache : false
            errorIcon.tooltip.text: !!networkConnectionStore ? networkConnectionStore.noBlockchainConnectionAndNoCacheText : ""
            onClicked: (itemId, mouse) => {
                           if (mouse.button === Qt.LeftButton) {
                               RootStore.getHistoricalDataForToken(modelData.symbol, root.currencyStore.currentCurrency)
                               d.selectedAssetIndex = delegateIndex
                               assetClicked(assetsListView.model.get(delegateIndex))
                           } else if (mouse.button === Qt.RightButton) {
                               Global.openMenu(tokenContextMenu, this,
                                               {symbol: modelData.symbol, assetName: modelData.name, assetImage: symbolUrl,
                                                   communityId: modelData.communityId, communityName: modelData.communityName, communityImage: modelData.communityImage})
                           }
                       }
            onSwitchToCommunityRequested: root.switchToCommunityRequested(communityId)
            Component.onCompleted: {
                // on Model reset if the detail view is shown, update the data in background.
                if(root.assetDetailsLaunched && delegateIndex === d.selectedAssetIndex) {
                    assetClicked(assetsListView.model.get(delegateIndex))
                }
            }
        }
    }

    Component {
        id: tokenContextMenu
        StatusMenu {
            onClosed: destroy()

            property string symbol
            property string assetName
            property string assetImage
            property string communityId
            property string communityName
            property string communityImage

            StatusAction {
                enabled: root.networkConnectionStore.sendBuyBridgeEnabled && !root.overview.isWatchOnlyAccount && root.overview.canSend
                visibleOnDisabled: true
                icon.name: "send"
                text: qsTr("Send")
                onTriggered: root.sendRequested(symbol)
            }
            StatusAction {
                icon.name: "receive"
                text: qsTr("Receive")
                onTriggered: root.receiveRequested(symbol)
            }
            StatusMenuSeparator {}
            StatusAction {
                icon.name: "settings"
                text: qsTr("Manage tokens")
                onTriggered: root.manageTokensRequested()
            }
            StatusAction {
                enabled: symbol !== Constants.ethToken
                type: StatusAction.Type.Danger
                icon.name: "hide"
                text: qsTr("Hide asset")
                onTriggered: Global.openConfirmHideAssetPopup(symbol, assetName, assetImage, !!communityId)
            }
            StatusAction {
                enabled: !!communityId
                type: StatusAction.Type.Danger
                icon.name: "hide"
                text: qsTr("Hide all assets from this community")
                onTriggered: Global.openPopup(confirmHideCommunityAssetsPopup, {communityId, communityName, communityImage})
            }
        }
    }

    Component {
        id: communityInfoPopupCmp
        CommunityAssetsInfoPopup {}
    }

    Component {
        id: confirmHideCommunityAssetsPopup
        ConfirmationDialog {
            property string communityId
            property string communityName
            property string communityImage

            width: 520
            destroyOnClose: true
            confirmButtonLabel: qsTr("Hide '%1' assets").arg(communityName)
            cancelBtnType: ""
            showCancelButton: true
            headerSettings.title: qsTr("Hide %1 community assets").arg(communityName)
            headerSettings.asset.name: communityImage
            confirmationText: qsTr("Are you sure you want to hide all community assets minted by %1? You will no longer see or be able to interact with these assets anywhere inside Status.").arg(communityName)
            onCancelButtonClicked: close()
            onConfirmButtonClicked: {
                root.controller.showHideGroup(communityId, false)
                close()
                Global.displayToastMessage(
                            qsTr("%1 community assets were successfully hidden. You can toggle asset visibility via %2.").arg(communityName)
                            .arg(`<a style="text-decoration:none" href="#${Constants.appSection.profile}/${Constants.settingsSubsection.wallet}/${Constants.walletSettingsSubsection.manageAssets}">` + qsTr("Settings", "Go to Settings") + "</a>"),
                            "",
                            "checkmark-circle",
                            false,
                            Constants.ephemeralNotificationType.success,
                            ""
                            )
            }
        }
    }
}
