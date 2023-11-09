import QtQuick 2.13
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import SortFilterProxyModel 0.2

import utils 1.0

import "../stores"
import shared.controls 1.0

Item {
    id: root

    property var assets
    property var networkConnectionStore
    property bool assetDetailsLaunched: false
    // we can check if model is empty to know if the assets were loaded
    // however , it would be more reliable to depend on the flag based on
    // the whenactual get assets api is called and returned.
    property bool areAssetsLoading

    signal assetClicked(var token)

    QtObject {
        id: d
        property int selectedAssetIndex: -1
        readonly property int loadingItemsCount: 25
    }

    StatusListView {
        id: assetListView
        objectName: "assetViewStatusListView"
        anchors.fill: parent
        model: areAssetsLoading ? d.loadingItemsCount : !!assets ? assets : null
        reuseItems: true
        delegate: delegateLoader
    }

    Component {
        id: delegateLoader
         Loader {
            property var modelData: model
            property int index: index
            width: ListView.view.width
            sourceComponent: areAssetsLoading ? loadingTokenDelegate: tokenDelegate
        }
    }

    Component {
        id: loadingTokenDelegate
        LoadingTokenDelegate {
            objectName: "AssetView_LoadingTokenDelegate_" + index
        }
    }

    Component {
        id: tokenDelegate
        TokenDelegate {
            objectName: "AssetView_TokenListItem_" + (!!modelData ? modelData.symbol : "")
            readonly property string balance: !!modelData ? "%1".arg(modelData.enabledNetworkBalance.amount) : "" // Needed for the tests
            errorTooltipText_1: !!modelData && !! networkConnectionStore ? networkConnectionStore.getBlockchainNetworkDownTextForToken(modelData.balances) : ""
            errorTooltipText_2: !!networkConnectionStore ? networkConnectionStore.getMarketNetworkDownText() : ""
            subTitle: {
                if (!modelData) {
                    return ""
                }
                if (networkConnectionStore && networkConnectionStore.noTokenBalanceAvailable) {
                    return ""
                }
                return LocaleUtils.currencyAmountToLocaleString(modelData.enabledNetworkBalance)
                
            }
            errorMode: !!networkConnectionStore ? networkConnectionStore.noBlockchainConnectionAndNoCache && !networkConnectionStore.noMarketConnectionAndNoCache : false
            errorIcon.tooltip.text: !!networkConnectionStore ? networkConnectionStore.noBlockchainConnectionAndNoCacheText : ""
            onClicked: {
                RootStore.getHistoricalDataForToken(modelData.symbol, RootStore.currencyStore.currentCurrency)
                d.selectedAssetIndex = index
                assetClicked(modelData)
            }
            Component.onCompleted: {
                // on Model reset if the detail view is shown, update the data in background.
                if(root.assetDetailsLaunched && index === d.selectedAssetIndex)
                    assetClicked(modelData)
            }
        }
    }
}
