import QtQuick 2.14
import shared 1.0
import shared.panels 1.0

import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Components 0.1

import utils 1.0

Column {
    id: root
    spacing: Style.current.padding
    anchors.horizontalCenter: parent.horizontalCenter
    topPadding: visible ? Style.current.bigPadding : 0
    bottomPadding: visible? 50 : 0

    property bool amIChatAdmin: false
    property string chatName: ""
    property string chatId: ""
    property int chatType: -1
    property string chatColor: ""
    property string chatEmoji: ""
    property string chatIcon: ""
    property bool didIJoinedChat: true

    signal joinChatClicked()
    signal rejectJoiningChatClicked()

    StatusSmartIdenticon {
        anchors.horizontalCenter: parent.horizontalCenter
        name: root.chatName
        icon {
            width: 120
            height: 120
            color: root.chatColor
            emoji: root.chatEmoji
            charactersLen: root.chatType === Constants.chatType.oneToOne ? 2 : 1
        }
        image {
            width: 120
            height: 120
            source: root.chatIcon
        }
        ringSettings.ringSpecModel: root.chatType === Constants.chatType.oneToOne ? Utils.getColorHashAsJson(root.chatId) : undefined
    }

    StyledText {
        id: channelName
        wrapMode: Text.Wrap
        text: root.chatName
        font.weight: Font.Bold
        font.pixelSize: 22
        color: Style.current.textColor
        anchors.horizontalCenter: parent.horizontalCenter
    }

    StyledText {
        id: descText
        wrapMode: Text.Wrap
        anchors.horizontalCenter: parent.horizontalCenter
        width: 310
        text: {
            switch(root.chatType) {
                case Constants.chatType.privateGroupChat:
                    //% "Welcome to the beginning of the <span style='color: %1'>%2</span> group!"
                    return qsTrId("welcome-to-the-beginning-of-the--span-style--color---1---2--span--group-").arg(Style.current.textColor).arg(root.chatName);
                case Constants.chatType.oneToOne:
                    //% "Any messages you send here are encrypted and can only be read by you and <span style='color: %1'>%2</span>"
                    return qsTrId("any-messages-you-send-here-are-encrypted-and-can-only-be-read-by-you-and--span-style--color---1---2--span-").arg(Style.current.textColor).arg(root.chatName)
                default: return "";
            }
        }
        font.pixelSize: Style.current.primaryTextFontSize
        color: Style.current.secondaryText
        horizontalAlignment: Text.AlignHCenter
        textFormat: Text.RichText
    }

    Item {
        id: joinOrDecline
        visible: root.chatType === Constants.chatType.privateGroupChat && !root.amIChatAdmin && !root.didIJoinedChat
        anchors.horizontalCenter: parent.horizontalCenter
        width: visible ? joinChat.width : 0
        height: visible ? 100 : 0

        StyledText {
            id: joinChat
            //% "Join chat"
            text: qsTrId("join-chat")
            font.pixelSize: 20
            color: Style.current.blue
            anchors.horizontalCenter: parent.horizontalCenter

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: {
                    root.joinChatClicked()
                    joinOrDecline.visible = false // Once we start getting member `joined` updates from `status-go` we can remove this
                }
            }
        }

        StyledText {
            //% "Decline invitation"
            text: qsTrId("group-chat-decline-invitation")
            font.pixelSize: 20
            color: Style.current.blue
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: joinChat.bottom
            anchors.topMargin: Style.current.padding
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: {
                    root.rejectJoiningChatClicked()
                    joinOrDecline.visible = false // Once we start getting member `joined` updates from `status-go` we can remove this
                }
            }
        }
    }
}
