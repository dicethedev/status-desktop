import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Layout 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import utils 1.0
import shared.controls 1.0
import shared.popups.keypairimport 1.0

import "popups"
import "panels"
import "views"
import "stores"
import "controls"

Item {
    id: root

    property bool hideSignPhraseModal: false
    property var store
    property var contactsStore
    property var communitiesStore
    property var emojiPopup: null
    property var sendModalPopup
    property var networkConnectionStore
    property bool appMainVisible

    onAppMainVisibleChanged: {
        resetView()
    }

    onVisibleChanged: {
        resetView()
    }

    Connections {
        target: walletSection

        function onFilterChanged(address) {
            RootStore.selectedAddress = address == "" ? "" : address
        }

        function onDisplayKeypairImportPopup() {
            keypairImport.active = true
        }

        function onDestroyKeypairImportPopup() {
            keypairImport.active = false
        }
    }

    enum LeftPanelSelection {
        AllAddresses,
        Address,
        SavedAddresses
    }

    enum RightPanelSelection {
        Assets,
        Collectibles,
        Activity
    }

    function resetView() {
        if (!visible || !appMainVisible) {
            return
        }

        d.displayAllAddresses()

        d.resetRightPanelStackView()

        if(!hideSignPhraseModal && !RootStore.hideSignPhraseModal){
            signPhrasePopup.open();
        }
    }

    function openDesiredView(leftPanelSelection, rightPanelSelection, data) {
        if (leftPanelSelection !== WalletLayout.LeftPanelSelection.AllAddresses &&
                leftPanelSelection !== WalletLayout.LeftPanelSelection.SavedAddresses &&
                leftPanelSelection !== WalletLayout.LeftPanelSelection.Address) {
            console.warn("not supported left selection", leftPanelSelection)
            return
        }

        if (leftPanelSelection === WalletLayout.LeftPanelSelection.SavedAddresses) {
            d.displaySavedAddresses()
        } else {
            let address = data.address ?? ""
            if (leftPanelSelection === WalletLayout.LeftPanelSelection.AllAddresses) {
                d.displayAllAddresses()
            } else if (leftPanelSelection === WalletLayout.LeftPanelSelection.Address) {
                if (!!address) {
                    d.displayAddress(address)
                } else {
                    d.displayAllAddresses()
                }
            }

            if (rightPanelSelection !== WalletLayout.RightPanelSelection.Collectibles &&
                    rightPanelSelection !== WalletLayout.RightPanelSelection.Assets &&
                    rightPanelSelection !== WalletLayout.RightPanelSelection.Activity) {
                console.warn("not supported right selection", rightPanelSelection)
                return
            }

            rightPanelStackView.currentItem.resetView()
            rightPanelStackView.currentItem.currentTabIndex = rightPanelSelection

            let txHash = data.txHash?? ""
            let savedAddress = data.savedAddress?? ""
            if (!!savedAddress) {
                RootStore.currentActivityFiltersStore.resetAllFilters()
                RootStore.currentActivityFiltersStore.toggleSavedAddress(savedAddress)
            } else if (!!txHash) {
                RootStore.currentActivityFiltersStore.resetAllFilters()
                RootStore.currentActivityFiltersStore.displayTxDetails(txHash)
            }
        }
    }

    QtObject {
        id: d

        readonly property bool showSavedAddresses: RootStore.showSavedAddresses
        onShowSavedAddressesChanged: {
            if(showSavedAddresses) {
                rightPanelStackView.replace(cmpSavedAddresses)
            } else {
                rightPanelStackView.replace(walletContainer)
            }
            RootStore.backButtonName = ""
        }

        function displayAllAddresses() {
            RootStore.showSavedAddresses = false
            RootStore.selectedAddress = ""
            RootStore.setFilterAllAddresses()
        }

        function displayAddress(address) {
            RootStore.showSavedAddresses = false
            RootStore.selectedAddress = address
            d.resetRightPanelStackView() // Avoids crashing on asset items being destroyed while in signal handler
            RootStore.setFilterAddress(address)
        }

        function displaySavedAddresses() {
            RootStore.showSavedAddresses = true
            RootStore.selectedAddress = ""
        }

        function resetRightPanelStackView() {
            if (rightPanelStackView.currentItem && !!rightPanelStackView.currentItem.resetView) {
                rightPanelStackView.currentItem.resetView()
            }
        }
    }

    SignPhraseModal {
        id: signPhrasePopup
        onRemindLaterClicked: hideSignPhraseModal = true
        onAcceptClicked: { RootStore.setHideSignPhraseModal(true); }
    }

    SeedPhraseBackupWarning {
        id: seedPhraseWarning
        width: parent.width
        anchors.top: parent.top
    }

    Component {
        id: cmpSavedAddresses
        SavedAddressesView {
            store: root.store
            contactsStore: root.contactsStore
            networkConnectionStore: root.networkConnectionStore
            sendModal: root.sendModalPopup

            networkFilter.visible: false
            headerButton.text: qsTr("Add new address")
            headerButton.onClicked: {
                Global.openAddEditSavedAddressesPopup({})
            }
        }
    }

    Component {
        id: walletContainer
        RightTabView {
            store: root.store
            contactsStore: root.contactsStore
            communitiesStore: root.communitiesStore
            sendModal: root.sendModalPopup
            networkConnectionStore: root.networkConnectionStore

            headerButton.text: RootStore.overview.ens || StatusQUtils.Utils.elideText(RootStore.overview.mixedcaseAddress, 6, 4)
            headerButton.visible: !RootStore.overview.isAllAccounts
            onLaunchShareAddressModal: Global.openShowQRPopup({
                                                                  switchingAccounsEnabled: true,
                                                                  changingPreferredChainsEnabled: true,
                                                                  hasFloatingButtons: true
                                                              })
        }
    }

    StatusSectionLayout {
        anchors.top: seedPhraseWarning.bottom
        height: root.height - seedPhraseWarning.height
        width: root.width
        backButtonName: RootStore.backButtonName
        notificationCount: activityCenterStore.unreadNotificationsCount
        hasUnseenNotifications: activityCenterStore.hasUnseenNotifications

        onNotificationButtonClicked: Global.openActivityCenterPopup()
        onBackButtonClicked: {
            rightPanelStackView.currentItem.resetStack();
        }

        leftPanel: LeftTabView {
            id: leftTab
            anchors.fill: parent
            emojiPopup: root.emojiPopup
            networkConnectionStore: root.networkConnectionStore

            changeSelectedAccount: function(address) {
                d.displayAddress(address)
            }
            selectAllAccounts: function() {
                d.displayAllAddresses()
            }
            selectSavedAddresses: function() {
                d.displaySavedAddresses()
            }
        }

        centerPanel: StackView {
            id: rightPanelStackView
            anchors.fill: parent
            anchors.leftMargin: 64
            anchors.rightMargin: 64
            initialItem: walletContainer
            replaceEnter: Transition {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 400; easing.type: Easing.OutCubic }
            }
            replaceExit: Transition {
                NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 400; easing.type: Easing.OutCubic }
            }
        }
        headerBackground: AccountHeaderGradient {
            width: parent.width
            overview: RootStore.overview
        }

        footer: WalletFooter {
            id: footer

            readonly property bool isHoldingSelected: !!walletStore.currentViewedCollectible && walletStore.currentViewedHoldingID !== ""
            readonly property bool isCommunityCollectible: !!walletStore.currentViewedCollectible ? walletStore.currentViewedCollectible.communityId !== "" : false
            readonly property bool isOwnerCommunityCollectible: isCommunityCollectible ? (walletStore.currentViewedCollectible.communityPrivilegesLevel === Constants.TokenPrivilegesLevel.Owner) : false

            visible: !RootStore.showAllAccounts
            width: parent.width
            height: RootStore.showAllAccounts ? implicitHeight : 61
            walletStore: RootStore
            networkConnectionStore: root.networkConnectionStore
            isCommunityOwnershipTransfer: footer.isHoldingSelected && footer.isOwnerCommunityCollectible
            communityName: {
                if (!walletStore.currentViewedCollectible)
                    return ""
                const name = walletStore.currentViewedCollectible.communityName
                const id = walletStore.currentViewedCollectible.communityId
                if (name === id)
                    return Utils.compactAddress(id, 4)
                return name
            }
            onLaunchShareAddressModal: Global.openShowQRPopup({
                                                                  switchingAccounsEnabled: true,
                                                                  changingPreferredChainsEnabled: true,
                                                                  hasFloatingButtons: true
                                                              })
            onLaunchSendModal: {
                if(isCommunityOwnershipTransfer) {
                    let tokenItem = walletStore.currentViewedCollectible
                    Global.openTransferOwnershipPopup(walletStore.currentViewedCollectible.communityId,
                                                      tokenItem.communityName,
                                                      tokenItem.communityImage,
                                                      {
                                                          "key": walletStore.currentViewedHoldingID,
                                                          "privilegesLevel": tokenItem.communityPrivilegesLevel,
                                                          "chainId": tokenItem.chainId,
                                                          "name": tokenItem.name,
                                                          "artworkSource": tokenItem.artworkSource,
                                                          "accountAddress": leftTab.currentAddress,
                                                          "tokenAddress": tokenItem.contractAddress
                                                      },
                                                      walletStore.accounts,
                                                      root.sendModalPopup)
                } else {
                    // Common send modal popup:
                    root.sendModalPopup.preSelectedSendType = Constants.SendType.Transfer
                    root.sendModalPopup.preSelectedHoldingID = walletStore.currentViewedHoldingID
                    root.sendModalPopup.preSelectedHoldingType = walletStore.currentViewedHoldingType
                    root.sendModalPopup.onlyAssets = false
                    root.sendModalPopup.open()
                }
            }
            onLaunchBridgeModal: {
                root.sendModalPopup.preSelectedSendType = Constants.SendType.Bridge
                root.sendModalPopup.preSelectedHoldingID = walletStore.currentViewedHoldingID
                root.sendModalPopup.preSelectedHoldingType = walletStore.currentViewedHoldingType
                root.sendModalPopup.onlyAssets = true
                root.sendModalPopup.open()
            }
        }
    }

    Loader {
        id: keypairImport
        active: false
        asynchronous: true

        sourceComponent: KeypairImportPopup {
            store.keypairImportModule: root.store.walletSectionInst.keypairImportModule
        }

        onLoaded: {
            keypairImport.item.open()
        }
    }
}
