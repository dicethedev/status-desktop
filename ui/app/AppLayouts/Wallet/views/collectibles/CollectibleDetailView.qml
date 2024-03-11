import QtQuick 2.14
import QtQuick.Layouts 1.13

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import AppLayouts.Communities.panels 1.0

import utils 1.0
import shared.controls 1.0
import shared.views 1.0

import "../../stores"
import "../../controls"

Item {
    id: root

    signal launchTransactionDetail(string txID)

    required property var rootStore
    required property var walletRootStore
    required property var communitiesStore

    required property var collectible
    property var activityModel
    property bool isCollectibleLoading

    // Community related token props:
    readonly property bool isCommunityCollectible: !!collectible ? collectible.communityId !== "" : false
    readonly property bool isOwnerTokenType: !!collectible ? (collectible.communityPrivilegesLevel === Constants.TokenPrivilegesLevel.Owner) : false
    readonly property bool isTMasterTokenType: !!collectible ? (collectible.communityPrivilegesLevel === Constants.TokenPrivilegesLevel.TMaster) : false

    readonly property var communityDetails: isCommunityCollectible ? root.communitiesStore.getCommunityDetailsAsJson(collectible.communityId) : null

    CollectibleDetailsHeader {
        id: collectibleHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        collectibleName: collectible.name
        collectibleId: "#" + collectible.tokenId
        collectionTag.tagPrimaryLabel.text: !!communityDetails ? communityDetails.name : collectible.collectionName
        isCollection: !!collectible.collectionName
        communityImage: !!communityDetails ? communityDetails.image: ""
        networkShortName: collectible.networkShortName
        networkColor: collectible.networkColor
        networkIconURL: collectible.networkIconUrl
        networkExplorerName: root.walletRootStore.getExplorerNameForNetwork(collectible.networkShortName)
        onCollectionTagClicked: {
            if (root.isCommunityCollectible) {
                Global.switchToCommunity(collectible.communityId)
            }
            /* TODO for non community token link out to collection on opensea
            https://github.com/status-im/status-desktop/issues/13918 */

        }
        onOpenCollectibleExternally: {
            /* TODO add link out to opensea
            https://github.com/status-im/status-desktop/issues/13918 */
        }
        onOpenCollectibleOnExplorer: Global.openLink("%1/nft/%2/%3".arg(root.walletRootStore.getExplorerUrl()).arg(collectible.contractAddress).arg(collectible.tokenId))
    }

    ColumnLayout {
        id: collectibleBody
        anchors.top: collectibleHeader.bottom
        anchors.topMargin: 25
        anchors.left: parent.left
        anchors.leftMargin: 52
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        spacing: Style.current.padding

        Row {
            id: collectibleImageDetails

            readonly property real visibleImageHeight: (collectibleimage.visible ? collectibleimage.height : privilegedCollectibleImage.height)
            readonly property real visibleImageWidth: (collectibleimage.visible ? collectibleimage.width : privilegedCollectibleImage.width)

            Layout.preferredHeight: collectibleImageDetails.visibleImageHeight
            Layout.preferredWidth: parent.width
            spacing: 24

            // Special artwork representation for community `Owner and Master Token` token types:
            PrivilegedTokenArtworkPanel {
                id: privilegedCollectibleImage

                visible: root.isCommunityCollectible && (root.isOwnerTokenType || root.isTMasterTokenType)
                size: PrivilegedTokenArtworkPanel.Size.Large
                artwork: collectible.imageUrl
                color: !!collectible && root.isCommunityCollectible? collectible.communityColor : "transparent"
                isOwner: root.isOwnerTokenType
            }

            StatusRoundedMedia {
                id: collectibleimage

                visible: !privilegedCollectibleImage.visible
                width: 248
                height: width
                radius: Style.current.radius
                color: collectible.backgroundColor
                border.color: Theme.palette.directColor8
                border.width: 1
                mediaUrl: collectible.mediaUrl ?? ""
                mediaType: collectible.mediaType ?? ""
                fallbackImageUrl: collectible.imageUrl
            }

            Column {
                id: collectibleNameAndDescription
                spacing: 12

                width: parent.width - collectibleImageDetails.visibleImageWidth - Style.current.bigPadding

                StatusBaseText {
                    id: collectibleName
                    width: parent.width
                    height: 24

                    text: root.isCommunityCollectible && !!communityDetails ? qsTr("Minted by %1").arg(root.communityDetails.name):  root.collectible.collectionName
                    color: Theme.palette.directColor1
                    font.pixelSize: 17
                    lineHeight: 24
                    lineHeightMode: Text.FixedHeight
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                }

                StatusScrollView {
                    id: descriptionScrollView
                    width: parent.width
                    height: collectibleImageDetails.height - collectibleName.height - parent.spacing

                    contentWidth: availableWidth

                    padding: 0
                    
                    StatusBaseText {
                        id: descriptionText
                        width: descriptionScrollView.availableWidth

                        text: collectible.description
                        textFormat: Text.MarkdownText
                        color: Theme.palette.directColor4
                        font.pixelSize: 15
                        lineHeight: 22
                        lineHeightMode: Text.FixedHeight
                        elide: Text.ElideRight
                        wrapMode: Text.Wrap
                    }
                }
            }
        }

        StatusTabBar {
            id: collectiblesDetailsTab
            Layout.fillWidth: true
            Layout.topMargin: Style.current.xlPadding
            visible: collectible.traits.count > 0

            StatusTabButton {
                leftPadding: 0
                width: implicitWidth
                text: qsTr("Properties")
            }
            StatusTabButton {
                rightPadding: 0
                width: implicitWidth
                text: qsTr("Activity")
            }
        }

        StatusScrollView {
            id: scrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth

            Loader {
                id: tabLoader
                Layout.fillWidth: true
                Layout.fillHeight: true
                sourceComponent: {
                    switch (collectiblesDetailsTab.currentIndex) {
                    case 0: return traitsView
                    case 1: return activityView
                    }
                }

                Component {
                    id: traitsView
                    Flow {
                        width: scrollView.availableWidth
                        spacing: 10
                        Repeater {
                            model: collectible.traits
                            InformationTile {
                                maxWidth: parent.width
                                primaryText: model.traitType
                                secondaryText: model.value
                            }
                        }
                    }
                }

                Component {
                    id: activityView
                        StatusListView {
                        width: scrollView.availableWidth
                        height: scrollView.availableHeight
                        model: root.activityModel
                        delegate: TransactionDelegate {
                            required property var model
                            required property int index
                            width: parent.width
                            modelData: model.activityEntry
                            timeStampText: isModelDataValid ? LocaleUtils.formatRelativeTimestamp(modelData.timestamp * 1000, true) : ""
                            rootStore: root.rootStore
                            walletRootStore: root.walletRootStore
                            showAllAccounts: root.walletRootStore.showAllAccounts
                            displayValues: true
                            community: isModelDataValid && !!communityId && !!root.communitiesStore ? root.communitiesStore.getCommunityDetailsAsJson(communityId) : null
                            loading: false
                            onClicked: {
                                if (mouse.button === Qt.RightButton) {
                                    // TODO: Implement context menu
                                } else {
                                    root.launchTransactionDetail(modelData.id)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
