import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.controls 1.0
import shared.views.chat 1.0

import "../helpers"
import "../controls"
import "../popups"
import "../panels"
import "../../Wallet"
import "../stores"

ColumnLayout {
    id: root

    // Important: each chat/channel has its own ChatContentModule
    property var chatContentModule
    property var chatSectionModule
    property var rootStore
    property var contactsStore
    property bool isActiveChannel: false
    property string chatId
    property int chatType: Constants.chatType.unknown

    readonly property alias chatMessagesLoader: chatMessagesLoader

    property var emojiPopup
    property var stickersPopup
    property UsersStore usersStore: UsersStore {}

    signal openAppSearch()
    signal openStickerPackPopup(string stickerPackId)

    property Component sendTransactionNoEnsModal
    property Component receiveTransactionModal
    property Component sendTransactionWithEnsModal

    property bool isBlocked: false
    property bool isUserAllowedToSendMessage: root.rootStore.isUserAllowedToSendMessage
    property string chatInputPlaceholder: root.rootStore.chatInputPlaceHolderText
    property bool stickersLoaded: false

    readonly property var messageStore: MessageStore {
        messageModule: chatContentModule ? chatContentModule.messagesModule : null
        chatSectionModule: root.rootStore.chatCommunitySectionModule
    }

    objectName: "chatContentViewColumn"
    spacing: 0

    onChatContentModuleChanged: if (!!chatContentModule) {
        root.usersStore.usersModule = root.chatContentModule.usersModule
    }

    QtObject {
        id: d

        function showReplyArea(messageId) {
            let obj = messageStore.getMessageByIdAsJson(messageId)
            if (!obj) {
                return
            }
            chatInput.showReplyArea(messageId, obj.senderDisplayName, obj.messageText, obj.contentType, obj.messageImage, obj.albumMessageImages, obj.albumImagesCount, obj.sticker)
        }
    }

    Loader {
        Layout.fillWidth: true
        active: root.isBlocked
        visible: active
        sourceComponent: StatusBanner {
            type: StatusBanner.Type.Danger
            statusText: qsTr("Blocked")
        }
    }

    Loader {
        id: chatMessagesLoader
        Layout.fillWidth: true
        Layout.fillHeight: true

        sourceComponent: ChatMessagesView {
            chatContentModule: root.chatContentModule
            rootStore: root.rootStore
            contactsStore: root.contactsStore
            messageStore: root.messageStore
            emojiPopup: root.emojiPopup
            stickersPopup: root.stickersPopup
            usersStore: root.usersStore
            stickersLoaded: root.stickersLoaded
            chatId: root.chatId
            isOneToOne: root.chatType === Constants.chatType.oneToOne
            isChatBlocked: root.isBlocked || !root.isUserAllowedToSendMessage
            channelEmoji: !chatContentModule ? "" : (chatContentModule.chatDetails.emoji || "")
            isActiveChannel: root.isActiveChannel
            onShowReplyArea: (messageId, senderId) => {
                d.showReplyArea(messageId)
            }
            onOpenStickerPackPopup: {
                root.openStickerPackPopup(stickerPackId);
            }
            onEditModeChanged: {
                if (!editModeOn)
                    chatInput.forceInputActiveFocus()
            }
        }
    }

    StatusChatInput {
        id: chatInput

        Layout.fillWidth: true
        Layout.margins: Style.current.smallPadding

        enabled: root.rootStore.sectionDetails.joined && !root.rootStore.sectionDetails.amIBanned &&
                 root.isUserAllowedToSendMessage

        store: root.rootStore
        usersStore: root.usersStore

        textInput.placeholderText: root.chatInputPlaceholder
        emojiPopup: root.emojiPopup
        stickersPopup: root.stickersPopup
        isContactBlocked: root.isBlocked
        isActiveChannel: root.isActiveChannel
        chatType: root.chatType
        suggestions.suggestionFilter.addSystemSuggestions: chatType === Constants.chatType.communityChat

        Binding on chatInputPlaceholder {
            when: root.isBlocked
            value: qsTr("This user has been blocked.")
        }

        Binding on chatInputPlaceholder {
            when: !root.rootStore.sectionDetails.joined || root.rootStore.sectionDetails.amIBanned
            value: qsTr("You need to join this community to send messages")
        }

        onSendTransactionCommandButtonClicked: {
            if(!chatContentModule) {
                console.debug("error on sending transaction command - chat content module is not set")
                return
            }

            if (Utils.isEnsVerified(chatContentModule.getMyChatId())) {
                Global.openPopup(root.sendTransactionWithEnsModal)
            } else {
                Global.openPopup(root.sendTransactionNoEnsModal)
            }
        }
        onReceiveTransactionCommandButtonClicked: {
            Global.openPopup(root.receiveTransactionModal)
        }
        onStickerSelected: {
            root.rootStore.sendSticker(chatContentModule.getMyChatId(),
                                                  hashId,
                                                  chatInput.isReply ? chatInput.replyMessageId : "",
                                                  packId,
                                                  url)
        }


        onSendMessage: {
            if (!chatContentModule) {
                console.debug("error on sending message - chat content module is not set")
                return
            }

            if(root.rootStore.sendMessage(chatContentModule.getMyChatId(),
                                          event,
                                          chatInput.getTextWithPublicKeys(),
                                          chatInput.isReply? chatInput.replyMessageId : "",
                                          chatInput.fileUrlsAndSources
                                          ))
            {
                Global.playSendMessageSound()

                chatInput.textInput.clear();
                chatInput.textInput.textFormat = TextEdit.PlainText;
                chatInput.textInput.textFormat = TextEdit.RichText;
            }
        }

        onUnblockChat: {
            chatContentModule.unblockChat()
        }
        onKeyUpPress: messageStore.setEditModeOnLastMessage(root.rootStore.userProfileInst.pubKey)

        Component.onCompleted: {
            Qt.callLater(() => {
                forceInputActiveFocus()
                textInput.cursorPosition = textInput.length
            })
        }
    }
}
