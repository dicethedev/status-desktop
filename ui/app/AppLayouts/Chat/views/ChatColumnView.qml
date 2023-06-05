import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ.Core.Theme 0.1
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

Item {
    id: root

    // Important: we have parent module in this context only cause qml components
    // don't follow struct we have on the backend.
    property var parentModule

    property var rootStore
    property var createChatPropertiesStore
    property var contactsStore
    property var emojiPopup
    property var stickersPopup

    property string activeChatId: parentModule && parentModule.activeItem.id
    property int chatsCount: parentModule && parentModule.model ? parentModule.model.count : 0
    property int activeChatType: parentModule && parentModule.activeItem.type
    property bool stickersLoaded: false

    readonly property var contactDetails: rootStore ? rootStore.oneToOneChatContact : null
    readonly property bool isUserAdded: root.contactDetails && root.contactDetails.isAdded

    signal openStickerPackPopup(string stickerPackId)

    function requestAddressForTransaction(address, amount, tokenAddress, tokenDecimals = 18) {
        amount =  globalUtils.eth2Wei(amount.toString(), tokenDecimals)

        parentModule.prepareChatContentModuleForChatId(activeChatId)
        let chatContentModule = parentModule.getChatContentModule()
        chatContentModule.inputAreaModule.requestAddress(address,
                                                    amount,
                                                    tokenAddress)
    }
    function requestTransaction(address, amount, tokenAddress, tokenDecimals = 18) {
        amount = globalUtils.eth2Wei(amount.toString(), tokenDecimals)


        parentModule.prepareChatContentModuleForChatId(activeChatId)
        let chatContentModule = parentModule.getChatContentModule()
        chatContentModule.inputAreaModule.request(address,
                                                    amount,
                                                    tokenAddress)
    }

    // This function is called once `1:1` or `group` chat is created.
    function checkForCreateChatOptions(chatId) {
        if(root.createChatPropertiesStore.createChatStartSendTransactionProcess) {
            if (root.contactDetails.ensVerified) {
                Global.openPopup(cmpSendTransactionWithEns);
            } else {
                Global.openPopup(cmpSendTransactionNoEns);
            }
        }
        else if (root.createChatPropertiesStore.createChatStartSendTransactionProcess) {
            Global.openPopup(cmpReceiveTransaction);
        }
        else if (root.createChatPropertiesStore.createChatStickerHashId !== "" &&
                 root.createChatPropertiesStore.createChatStickerPackId !== "" &&
                 root.createChatPropertiesStore.createChatStickerUrl !== "") {
            root.rootStore.sendSticker(chatId,
                                       root.createChatPropertiesStore.createChatStickerHashId,
                                       "",
                                       root.createChatPropertiesStore.createChatStickerPackId,
                                       root.createChatPropertiesStore.createChatStickerUrl);
        }
        else if (root.createChatPropertiesStore.createChatInitMessage !== "" ||
                 root.createChatPropertiesStore.createChatFileUrls.length > 0) {

            root.rootStore.sendMessage(chatId,
                                       Qt.Key_Enter,
                                       root.createChatPropertiesStore.createChatInitMessage,
                                       "",
                                       root.createChatPropertiesStore.createChatFileUrls
                                       );
        }

        root.createChatPropertiesStore.resetProperties()
    }

    QtObject {
        id: d

        property var activeChatContentModule: d.getChatContentModule(root.activeChatId)

        readonly property UsersStore activeUsersStore: UsersStore {
            usersModule: !!d.activeChatContentModule ? d.activeChatContentModule.usersModule : null
        }

        readonly property MessageStore activeMessagesStore: MessageStore {
            messageModule: d.activeChatContentModule ? d.activeChatContentModule.messagesModule : null
            chatSectionModule: root.rootStore.chatCommunitySectionModule
        }

        function getChatContentModule(chatId) {
            root.parentModule.prepareChatContentModuleForChatId(chatId)
            return root.parentModule.getChatContentModule()
        }

        function showReplyArea(messageId) {
            const obj = d.activeMessagesStore.getMessageByIdAsJson(messageId)
            if (!obj)
                return
            chatInput.showReplyArea(messageId,
                                    obj.senderDisplayName,
                                    obj.messageText,
                                    obj.contentType,
                                    obj.messageImage,
                                    obj.albumMessageImages,
                                    obj.albumImagesCount,
                                    obj.sticker)
        }

        function restoreInputReply() {
            const replyMessageId = d.activeChatContentModule.inputAreaModule.preservedProperties.replyMessageId
            if (replyMessageId)
                d.showReplyArea(replyMessageId)
            else
                chatInput.resetReplyArea()
        }

        function restoreInputAttachments() {
            const filesJson = d.activeChatContentModule.inputAreaModule.preservedProperties.fileUrlsAndSourcesJson
            let filesList = []
            if (filesJson) {
                try {
                    filesList = JSON.parse(filesJson)
                } catch(e) {
                    console.error("failed to parse preserved fileUrlsAndSources")
                }
            }
            chatInput.resetImageArea()
            chatInput.validateImagesAndShowImageArea(filesList)
        }

        function fixUsersStore() {
            d.activeUsersStore.usersModule = Qt.binding(() => {
                                                            return !!d.activeChatContentModule ? d.activeChatContentModule.usersModule : null
                                                        })
        }

        function fixMessageStore() {
            d.activeMessagesStore.messageModule = Qt.binding(() => {
                                                                 return d.activeChatContentModule ? d.activeChatContentModule.messagesModule : null
                                                             })
        }

        onActiveChatContentModuleChanged: {
            // Force immediate update of dependand stores
            d.fixUsersStore()
            d.fixMessageStore()

            if (!d.activeChatContentModule) {
                chatInput.textInput.text = ""
                chatInput.resetReplyArea()
                chatInput.resetImageArea()
                return
            }

            // Restore message text
            chatInput.textInput.text = d.activeChatContentModule.inputAreaModule.preservedProperties.text
            chatInput.textInput.cursorPosition = chatInput.textInput.length

            d.restoreInputReply()
            d.restoreInputAttachments()
        }
    }

    Component.onCompleted: {
        d.fixUsersStore()
        d.fixMessageStore()
    }

    EmptyChatPanel {
        anchors.fill: parent
        visible: root.activeChatId === "" || root.chatsCount == 0
        rootStore: root.rootStore
        onShareChatKeyClicked: Global.openProfilePopup(userProfile.pubKey);
    }

    // This is kind of a solution for applying backend refactored changes with the minimal qml changes.
    // The best would be if we made qml to follow the struct we have on the backend side.

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Repeater {
                id: chatRepeater
                model: parentModule && parentModule.model

                ChatContentView {
                    width: parent.width
                    height: parent.height
                    visible: !root.rootStore.openCreateChat && model.active
                    chatId: model.itemId
                    chatType: model.type
                    chatMessagesLoader.active: model.loaderActive
                    rootStore: root.rootStore
                    contactsStore: root.contactsStore
                    emojiPopup: root.emojiPopup
                    stickersPopup: root.stickersPopup
                    stickersLoaded: root.stickersLoaded
                    isBlocked: model.blocked
                    onOpenStickerPackPopup: {
                        root.openStickerPackPopup(stickerPackId)
                    }
                    onShowReplyArea: (messageId) => {
                        d.showReplyArea(messageId)
                    }
                    onForceInputFocus: {
                        chatInput.forceInputActiveFocus()
                    }

                    Component.onCompleted: {
                        chatContentModule = d.getChatContentModule(model.itemId)
                        chatSectionModule = root.parentModule
                        root.checkForCreateChatOptions(model.itemId)
                    }
                }
            }
        }

        StatusChatInput {
            id: chatInput

            Layout.fillWidth: true
            Layout.margins: Style.current.smallPadding

            enabled: root.rootStore.sectionDetails.joined && !root.rootStore.sectionDetails.amIBanned &&
                     root.rootStore.isUserAllowedToSendMessage

            store: root.rootStore
            usersStore: d.usersStore

            textInput.placeholderText: {
                if (d.activeChatContentModule.chatDetails.blocked)
                    return qsTr("This user has been blocked.")
                if (!root.rootStore.sectionDetails.joined || root.rootStore.sectionDetails.amIBanned)
                    return qsTr("You need to join this community to send messages")
                return root.rootStore.chatInputPlaceHolderText
            }

            emojiPopup: root.emojiPopup
            stickersPopup: root.stickersPopup
            isContactBlocked: d.activeChatContentModule.chatDetails.blocked
            chatType: root.activeChatType
            suggestions.suggestionFilter.addSystemSuggestions: chatType === Constants.chatType.communityChat

            textInput.onTextChanged: {
                d.activeChatContentModule.inputAreaModule.preservedProperties.text = textInput.text
            }

            onReplyMessageIdChanged: {
                d.activeChatContentModule.inputAreaModule.preservedProperties.replyMessageId = replyMessageId
            }

            onFileUrlsAndSourcesChanged: {
                d.activeChatContentModule.inputAreaModule.preservedProperties.fileUrlsAndSourcesJson = JSON.stringify(chatInput.fileUrlsAndSources)
            }

            // TODO: A lot of chatContentModule.getMyChatId is used here. Isn't it just `root.activeChatId`?

            onSendTransactionCommandButtonClicked: {
                if (!d.activeChatContentModule) {
                    console.warn("error on sending transaction command - chat content module is not set")
                    return
                }

                if (Utils.isEnsVerified(d.activeChatContentModule.getMyChatId())) {
                    Global.openPopup(cmpSendTransactionWithEns)
                } else {
                    Global.openPopup(cmpSendTransactionNoEns)
                }
            }

            onReceiveTransactionCommandButtonClicked: {
                Global.openPopup(cmpReceiveTransaction)
            }

            onStickerSelected: {
                root.rootStore.sendSticker(d.activeChatContentModule.getMyChatId(),
                                                      hashId,
                                                      chatInput.isReply ? chatInput.replyMessageId : "",
                                                      packId,
                                                      url)
            }


            onSendMessage: {
                if (!d.activeChatContentModule) {
                    console.debug("error on sending message - chat content module is not set")
                    return
                }

                if (root.rootStore.sendMessage(d.activeChatContentModule.getMyChatId(),
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
                d.activeChatContentModule.unblockChat()
            }

            onKeyUpPress: {
                d.activeMessagesStore.setEditModeOnLastMessage(root.rootStore.userProfileInst.pubKey)
            }

            Component.onCompleted: {
                Qt.callLater(() => {
                            // TODO: Review, is this needed now?
                    forceInputActiveFocus()
                    textInput.cursorPosition = textInput.length
                })
            }
        }
    }


    Component {
        id: cmpSendTransactionNoEns
        ChatCommandModal {
            store: root.rootStore
            contactsStore: root.contactsStore
            onClosed: {
                destroy()
            }
            sendChatCommand: root.requestAddressForTransaction
            isRequested: false
            commandTitle: qsTr("Send")
            header.title: commandTitle
            finalButtonLabel: qsTr("Request Address")
            selectRecipient.selectedRecipient: {
                parentModule.prepareChatContentModuleForChatId(activeChatId)
                let chatContentModule = parentModule.getChatContentModule()
                return {
                    address: Constants.zeroAddress, // Setting as zero address since we don't have the address yet
                    alias: chatContentModule.chatDetails.name, // Do we need the alias for real or name works?
                    pubKey: chatContentModule.chatDetails.id,
                    icon: chatContentModule.chatDetails.icon,
                    name: chatContentModule.chatDetails.name,
                    type: RecipientSelector.Type.Contact,
                    ensVerified: true
                }
            }
            selectRecipient.selectedType: RecipientSelector.Type.Contact
            selectRecipient.readOnly: true
        }
    }

    Component {
        id: cmpReceiveTransaction
        ChatCommandModal {
            store: root.rootStore
            contactsStore: root.contactsStore
            onClosed: {
                destroy()
            }
            sendChatCommand: root.requestTransaction
            isRequested: true
            commandTitle: qsTr("Request")
            header.title: commandTitle
            finalButtonLabel: qsTr("Request")
            selectRecipient.selectedRecipient: {
                parentModule.prepareChatContentModuleForChatId(activeChatId)
                let chatContentModule = parentModule.getChatContentModule()
                return {
                    address: Constants.zeroAddress, // Setting as zero address since we don't have the address yet
                    alias: chatContentModule.chatDetails.name, // Do we need the alias for real or name works?
                    pubKey: chatContentModule.chatDetails.id,
                    icon: chatContentModule.chatDetails.icon,
                    name: chatContentModule.chatDetails.name,
                    type: RecipientSelector.Type.Contact
                }
            }
            selectRecipient.selectedType: RecipientSelector.Type.Contact
            selectRecipient.readOnly: true
        }
    }

    Component {
        id: cmpSendTransactionWithEns
        SendModal {
            onClosed: {
                destroy()
            }
            preSelectedRecipient: {
                parentModule.prepareChatContentModuleForChatId(activeChatId)
                let chatContentModule = parentModule.getChatContentModule()

                return {
                    address: "",
                    alias: chatContentModule.chatDetails.name, // Do we need the alias for real or name works?
                    identicon: chatContentModule.chatDetails.icon,
                    name: chatContentModule.chatDetails.name,
                    type: RecipientSelector.Type.Contact,
                    ensVerified: true
                }
            }
        }
    }
}
