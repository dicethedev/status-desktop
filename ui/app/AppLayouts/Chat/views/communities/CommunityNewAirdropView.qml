import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0
import shared.panels 1.0

import AppLayouts.Chat.controls.community 1.0
import AppLayouts.Chat.helpers 1.0
import AppLayouts.Chat.panels.communities 1.0
import AppLayouts.Chat.popups.community 1.0

import SortFilterProxyModel 0.2


StatusScrollView {
    id: root

    // Token models:
    required property var assetsModel
    required property var collectiblesModel

    // Community members model:
    required property var membersModel

    // JS object specifing fees for the airdrop operation, should be set to
    // provide response to airdropFeesRequested signal.
    //
    // The expected structure is as follows:
    // {
    //    fees: [{
    //      ethFee: {CurrencyAmount JSON},
    //      fiatFee: {CurrencyAmount JSON},
    //      contractUniqueKey: string,
    //      errorCode: ComputeFeeErrorCode (int)
    //    }],
    //    totalEthFee: {CurrencyAmount JSON},
    //    totalFiatFee: {CurrencyAmount JSON},
    //    errorCode: ComputeFeeErrorCode (int)
    // }
    property var airdropFees: null

    property int viewWidth: 560 // by design

    readonly property var selectedHoldingsModel: ListModel {}

    ModelChangeTracker {
        id: holdingsModelTracker

        model: selectedHoldingsModel
    }

    ModelChangeTracker {
        id: addressesModelTracker

        model: addresses
    }

    ModelChangeTracker {
        id: membersModelTracker

        model: selectedMembersModel
    }

    readonly property bool isFullyFilled: tokensSelector.count > 0 &&
                                          airdropRecipientsSelector.count > 0 &&
                                          airdropRecipientsSelector.valid

    signal airdropClicked(var airdropTokens, var addresses, var membersPubKeys)

    signal airdropFeesRequested(var contractKeysAndAmounts, var addresses)

    signal navigateToMintTokenSettings(bool isAssetType)

    function selectToken(key, amount, type) {
        if(selectedHoldingsModel)
            selectedHoldingsModel.clear()
        var tokenModel = null
        if(type === Constants.TokenType.ERC20)
            tokenModel = root.assetsModel
        else if (type === Constants.TokenType.ERC721)
            tokenModel = root.collectiblesModel

        const modelItem = CommunityPermissionsHelpers.getTokenByKey(
                            tokenModel, key)

        const entry = d.prepareEntry(key, amount, type)
        entry.valid = true
        selectedHoldingsModel.append(entry)
    }

    function addAddresses(_addresses) {
        addresses.addAddresses(_addresses)
    }

    onAirdropFeesChanged: {
        if (root.airdropFees === null)
            return

        const fees = root.airdropFees.fees
        const errorCode = root.airdropFees.errorCode

        function buildFeeString(ethFee, fiatFee) {
            return `${LocaleUtils.currencyAmountToLocaleString(ethFee)} (${LocaleUtils.currencyAmountToLocaleString(fiatFee)})`
        }

        d.feesError = ""
        d.totalFee = ""

        if (errorCode === Constants.ComputeFeeErrorCode.Infura) {
            d.feesError = qsTr("Infura error")
            return
        }

        if (errorCode === Constants.ComputeFeeErrorCode.Success ||
                errorCode === Constants.ComputeFeeErrorCode.Balance) {
            fees.forEach(fee => {
                const idx = ModelUtils.indexOf(
                                 feesModel, "contractUniqueKey",
                                 fee.contractUniqueKey)

                feesModel.set(idx, {
                    feeText: buildFeeString(fee.ethFee, fee.fiatFee)
                })
            })

            d.totalFee = buildFeeString(
                        root.airdropFees.totalEthFee,
                        root.airdropFees.totalFiatFee)

            if (errorCode === Constants.ComputeFeeErrorCode.Balance) {
                d.feesError = qsTr("Your account does not have enough ETH to pay the gas fee for this airdrop. Try adding some ETH to your account.")
            }

            return
        }

        d.feesError = qsTr("Unknown error")
    }

    QtObject {
        id: d

        readonly property int maxAirdropTokens: 5
        readonly property int dropdownHorizontalOffset: 4
        readonly property int dropdownVerticalOffset: 1

        property string feesError
        property string totalFee

        readonly property bool isFeeLoading:
            root.airdropFees === null ||
            (root.airdropFees.errorCode !== Constants.ComputeFeeErrorCode.Success &&
             root.airdropFees.errorCode !== Constants.ComputeFeeErrorCode.Balance)

        readonly property bool showFees: root.selectedHoldingsModel.count > 0
                                         && airdropRecipientsSelector.valid
                                         && airdropRecipientsSelector.count > 0

        readonly property int totalRevision: holdingsModelTracker.revision
                                             + addressesModelTracker.revision
                                             + membersModelTracker.revision
                                             + (d.showFees ? 1 : 0)

        onTotalRevisionChanged: {
            Qt.callLater(() => {
                if (!d.showFees)
                    return

                d.resetFees()
            })
        }

        function prepareEntry(key, amount, type) {
            let tokenModel = null
            if(type === Constants.TokenType.ERC20)
                tokenModel = root.assetsModel
            else if (type === Constants.TokenType.ERC721)
                tokenModel = root.collectiblesModel

            const modelItem = CommunityPermissionsHelpers.getTokenByKey(
                                tokenModel, key)

            return {
                key, amount, type,
                tokenText: amount + " " + modelItem.name,
                tokenImage: modelItem.iconSource,
                networkText: modelItem.chainName,
                networkImage: Style.svg(modelItem.chainIcon),
                supply: modelItem.supply,
                infiniteSupply: modelItem.infiniteSupply,
                contractUniqueKey: modelItem.contractUniqueKey,
                accountName: modelItem.accountName,
                symbol: modelItem.symbol
            }
        }

        function rebuildFeesModel() {
            feesModel.clear()

            const airdropTokens = ModelUtils.modelToArray(
                                    root.selectedHoldingsModel,
                                    ["contractUniqueKey", "accountName",
                                     "symbol", "amount", "tokenText",
                                     "networkText"])

            airdropTokens.forEach(entry => {
                feesModel.append({
                    contractUniqueKey: entry.contractUniqueKey,
                    amount: entry.amount * addresses.count,
                    account: entry.accountName,
                    symbol: entry.symbol,
                    network: entry.networkText,
                    feeText: ""
                })
            })
        }

        function requestFees() {
            const airdropTokens = ModelUtils.modelToArray(
                                    root.selectedHoldingsModel,
                                    ["contractUniqueKey", "amount"])

            const contractKeysAndAmounts = airdropTokens.map(item => ({
                amount: item.amount,
                contractUniqueKey: item.contractUniqueKey
            }))
            const addressesArray = ModelUtils.modelToArray(
                                     addresses, ["address"]).map(e => e.address)

            airdropFeesRequested(contractKeysAndAmounts, addressesArray)
        }

        function resetFees() {
            root.airdropFees = null
            d.feesError = ""
            d.totalFee = ""

            d.rebuildFeesModel()
            d.requestFees()
        }
    }

    ListModel {
        id: feesModel
    }

    Instantiator {
        id: recipientsCountInstantiator

        model: selectedHoldingsModel

        property bool infinity: true
        property int maximumRecipientsCount

        function findRecipientsCount() {
            let min = Number.MAX_SAFE_INTEGER

            for (let i = 0; i < count; i++) {
                const item = objectAt(i)

                if (!item || item.infiniteSupply)
                    continue

                min = Math.min(item.supply / item.amount, min)
            }

            infinity = min === Number.MAX_SAFE_INTEGER
            maximumRecipientsCount = infinity ? 0 : min
        }

        delegate: QtObject {
            readonly property int supply: model.supply
            readonly property real amount: model.amount
            readonly property bool infiniteSupply: model.infiniteSupply

            readonly property bool valid:
                infiniteSupply || amount * airdropRecipientsSelector.count <= supply

            onSupplyChanged: recipientsCountInstantiator.findRecipientsCount()
            onAmountChanged: recipientsCountInstantiator.findRecipientsCount()
            onInfiniteSupplyChanged: recipientsCountInstantiator.findRecipientsCount()

            onValidChanged: model.valid = valid
            Component.onCompleted: model.valid = valid
        }

        onCountChanged: findRecipientsCount()
    }

    SequenceColumnLayout {
        id: mainLayout
        width: root.viewWidth
        spacing: 0

        AirdropTokensSelector {
            id: tokensSelector

            property int editedIndex: -1

            Layout.fillWidth: true
            icon: Style.svg("token")
            title: qsTr("What")
            placeholderText: qsTr("Example: 1 SOCK")
            addButton.visible: model.count < d.maxAirdropTokens

            model: root.selectedHoldingsModel

            HoldingsDropdown {
                id: dropdown

                assetsModel: root.assetsModel
                collectiblesModel: root.collectiblesModel
                isENSTab: false
                noDataTextForAssets: qsTr("First you need to mint or import an asset before you can perform an airdrop")
                noDataTextForCollectibles: qsTr("First you need to mint or import a collectible before you can perform an airdrop")

                function getHoldingIndex(key) {
                    return ModelUtils.indexOf(root.selectedHoldingsModel, "key", key)
                }

                function prepareUpdateIndex(key) {
                    const itemIndex = tokensSelector.editedIndex
                    const existingIndex = getHoldingIndex(key)

                    if (itemIndex !== -1 && existingIndex !== -1 && itemIndex !== existingIndex) {
                        const previousKey = root.selectedHoldingsModel.get(itemIndex).key
                        root.selectedHoldingsModel.remove(existingIndex)
                        return getHoldingIndex(previousKey)
                    }

                    if (itemIndex === -1) {
                        return existingIndex
                    }

                    return itemIndex
                }

                onOpened: {
                    usedTokens = ModelUtils.modelToArray(
                                root.selectedHoldingsModel, ["key", "amount"])
                }

                onAddAsset: {
                    const entry = d.prepareEntry(key, amount, Constants.TokenType.ERC20)
                    entry.valid = true

                    selectedHoldingsModel.append(entry)
                    dropdown.close()
                }

                onAddCollectible: {
                    const entry = d.prepareEntry(key, amount, Constants.TokenType.ERC721)
                    entry.valid = true

                    selectedHoldingsModel.append(entry)
                    dropdown.close()
                }

                onUpdateAsset: {
                    const itemIndex = prepareUpdateIndex(key)

                    const entry = d.prepareEntry(key, amount, Constants.TokenType.ERC20)

                    root.selectedHoldingsModel.set(itemIndex, entry)
                    dropdown.close()
                }

                onUpdateCollectible: {
                    const itemIndex = prepareUpdateIndex(key)

                    const entry = d.prepareEntry(key, amount, Constants.TokenType.ERC721)

                    root.selectedHoldingsModel.set(itemIndex, entry)
                    dropdown.close()
                }

                onRemoveClicked: {
                    root.selectedHoldingsModel.remove(tokensSelector.editedIndex)
                    dropdown.close()
                }

                onNavigateToMintTokenSettings: {
                    root.navigateToMintTokenSettings(isAssetType)
                    close()
                }
            }

            addButton.onClicked: {
                dropdown.parent = tokensSelector.addButton
                dropdown.x = tokensSelector.addButton.width + d.dropdownHorizontalOffset
                dropdown.y = 0
                dropdown.open()

                editedIndex = -1
            }

            onItemClicked: {
                if (mouse.button !== Qt.LeftButton)
                    return

                dropdown.parent = item
                dropdown.x = mouse.x + d.dropdownHorizontalOffset
                dropdown.y = d.dropdownVerticalOffset

                const modelItem = selectedHoldingsModel.get(index)

                switch(modelItem.type) {
                    case HoldingTypes.Type.Asset:
                        dropdown.assetKey = modelItem.key
                        dropdown.assetAmount = modelItem.amount
                        dropdown.setActiveTab(HoldingTypes.Type.Asset)
                        break
                    case HoldingTypes.Type.Collectible:
                        dropdown.collectibleKey = modelItem.key
                        dropdown.collectibleAmount = modelItem.amount
                        dropdown.setActiveTab(HoldingTypes.Type.Collectible)
                        break
                    default:
                        console.warn("Unsupported token type.")
                }

                dropdown.openUpdateFlow()

                editedIndex = index
            }
        }

        SequenceColumnLayout.Separator {}

        AirdropRecipientsSelector {
            id: airdropRecipientsSelector

            addressesModel: addresses

            infiniteMaxNumberOfRecipients:
                recipientsCountInstantiator.infinity

            maxNumberOfRecipients:
                recipientsCountInstantiator.maximumRecipientsCount

            membersModel: SortFilterProxyModel {
                id: selectedMembersModel

                sourceModel: membersModel

                filters: ExpressionFilter {
                    id: selectedKeysFilter

                    property var keys: new Set()

                    expression: keys.has(model.pubKey)
                }
            }

            onRemoveMemberRequested: {
                const pubKey = ModelUtils.get(membersModel, index, "pubKey")

                selectedKeysFilter.keys.delete(pubKey)
                selectedKeysFilter.keys = new Set([...selectedKeysFilter.keys])
            }

            onAddAddressesRequested: (addresses_) => {
                addresses.addAddressesFromString(addresses_)
                airdropRecipientsSelector.clearAddressesInput()
                airdropRecipientsSelector.positionAddressesListAtEnd()
            }

            onRemoveAddressRequested: addresses.remove(index)

            ListModel {
                id: addresses

                function addAddresses(_addresses) {
                    const existing = new Set()

                    for (let i = 0; i < count; i++)
                        existing.add(get(i).address)

                    _addresses.forEach(address => {
                        if (existing.has(address))
                            return

                        const valid = Utils.isValidAddress(address)
                        append({ valid, address })
                    })
                }

                function addAddressesFromString(addressesString) {
                    const words = addressesString.trim().split(/[\s+,]/)
                    const wordsNonEmpty = words.filter(word => !!word)

                    addAddresses(wordsNonEmpty)
                }
            }

            function openPopup(popup) {
                popup.parent = addButton
                popup.x = addButton.width + d.dropdownHorizontalOffset
                popup.y = 0

                popup.open()
            }

            addButton.onClicked: openPopup(recipientTypeSelectionDropdown)

            RecipientTypeSelectionDropdown {
                id: recipientTypeSelectionDropdown

                onEthAddressesSelected: {
                    airdropRecipientsSelector.showAddressesInputWhenEmpty = true
                    airdropRecipientsSelector.forceInputFocus()
                    recipientTypeSelectionDropdown.close()
                }

                onCommunityMembersSelected: {
                    recipientTypeSelectionDropdown.close()
                    membersDropdown.selectedKeys = selectedKeysFilter.keys

                    const hasSelection =  selectedKeysFilter.keys.size !== 0

                    membersDropdown.mode = hasSelection
                            ? MembersDropdown.Mode.Update
                            : MembersDropdown.Mode.Add

                    airdropRecipientsSelector.openPopup(membersDropdown)
                }
            }

            MembersDropdown {
                id: membersDropdown

                forceButtonDisabled:
                    mode === MembersDropdown.Mode.Update &&
                    [...selectedKeys].sort().join() === [...selectedKeysFilter.keys].sort().join()

                model: SortFilterProxyModel {
                    sourceModel: membersModel

                    filters: [
                        ExpressionFilter {
                            enabled: membersDropdown.searchText !== ""

                            function matchesAlias(name, filter) {
                                return name.split(" ").some(p => p.startsWith(filter))
                            }

                            expression: {
                                membersDropdown.searchText

                                const filter = membersDropdown.searchText.toLowerCase()
                                return matchesAlias(model.alias.toLowerCase(), filter)
                                         || model.displayName.toLowerCase().includes(filter)
                                         || model.ensName.toLowerCase().includes(filter)
                                         || model.localNickname.toLowerCase().includes(filter)
                                         || model.pubKey.toLowerCase().includes(filter)
                            }
                        }
                    ]
                }

                onBackButtonClicked: {
                    close()
                    airdropRecipientsSelector.openPopup(
                                recipientTypeSelectionDropdown)
                }

                onAddButtonClicked: {
                    selectedKeysFilter.keys = selectedKeys
                    close()
                }
            }
        }

        SequenceColumnLayout.Separator {}

        StatusGroupBox {
            id: feesBox

            Layout.fillWidth: true
            implicitWidth: 0

            title: qsTr("Fees")
            icon: Style.svg("gas")

            Control {
                id: feesControl

                width: feesBox.availableWidth

                padding: Style.current.padding
                verticalPadding: 18

                background: Rectangle {
                    radius: Style.current.radius
                    color: Theme.palette.indirectColor1
                }

                contentItem: Loader {
                    Component {
                        id: feesPanelComponent

                        FeesPanel {
                            width: feesControl.availableWidth

                            showAccounts: false
                            totalFeeText: d.totalFee
                            showSummary: count > 1
                            isFeeLoading: d.isFeeLoading

                            model: feesModel
                        }
                    }

                    Component {
                        id: placeholderComponent

                        StatusBaseText {
                            width: feesControl.availableWidth

                            text: qsTr("Add valid “What” and “To” values to see fees")
                            font.pixelSize: Style.current.primaryTextFontSize
                            elide: Text.ElideRight
                            color: Theme.palette.baseColor1
                        }
                    }

                    sourceComponent: d.showFees ? feesPanelComponent
                                                : placeholderComponent
                }
            }
        }

        WarningPanel {
            id: notEnoughTokensWarning

            Layout.fillWidth: true
            Layout.topMargin: Style.current.padding

            text: qsTr("Not enough tokens to send to all recipients. Reduce the number of recipients or change the number of tokens sent to each recipient.")

            visible: !recipientsCountInstantiator.infinity &&
                     recipientsCountInstantiator.maximumRecipientsCount < airdropRecipientsSelector.count
        }

        WarningPanel {
            Layout.fillWidth: true
            Layout.topMargin: Style.current.padding

            text: d.feesError

            visible: !notEnoughTokensWarning.visible && d.showFees && d.feesError
        }

        StatusButton {
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.topMargin: Style.current.bigPadding
            text: qsTr("Create airdrop")
            enabled: root.isFullyFilled && !d.isFeeLoading && d.feesError === ""

            onClicked: {
                feesPopup.open()
            }
        }

        SignMultiTokenTransactionsPopup {
            id: feesPopup

            destroyOnClose: false

            model: feesModel

            isFeeLoading: d.isFeeLoading

            totalFeeText: d.totalFee
            errorText: d.feesError

            onOpened: {
                const title1 = qsTr("Sign transaction - Airdrop %n token(s)", "",
                                    selectedHoldingsModel.rowCount())
                const title2 = qsTr("to %n recipient(s)", "",
                                    addresses.count + airdropRecipientsSelector.membersModel.count)

                title = `${title1} ${title2}`

                d.resetFees()
            }

            onSignTransactionClicked: {
                const airdropTokens = ModelUtils.modelToArray(
                                        root.selectedHoldingsModel,
                                        ["contractUniqueKey", "amount"])

                const addresses_ = ModelUtils.modelToArray(
                                    addresses, ["address"]).map(e => e.address)

                const pubKeys = [...selectedKeysFilter.keys]

                root.airdropClicked(airdropTokens, addresses_, pubKeys)
            }
        }
    }
}
