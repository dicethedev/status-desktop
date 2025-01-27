import NimQml, Tables, json, sequtils

import ./io_interface, ./view, ./controller, ./token_data_item
import ../io_interface as delegate_interface
import ./item as notification_item
import ../../shared_models/message_item as msg_item
import ../../shared_models/message_item_qobject as msg_item_qobj
import ../../shared_models/message_transaction_parameters_item
import ../../../global/global_singleton
import ../../../core/eventemitter
import ../../../../app_service/service/activity_center/service as activity_center_service
import ../../../../app_service/service/contacts/service as contacts_service
import ../../../../app_service/service/message/service as message_service
import ../../../../app_service/service/chat/service as chat_service
import ../../../../app_service/service/community/service as community_service

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: Controller
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*(
    delegate: delegate_interface.AccessInterface,
    events: EventEmitter,
    activityCenterService: activity_center_service.Service,
    contactsService: contacts_service.Service,
    messageService: message_service.Service,
    chatService: chat_service.Service,
    communityService: community_service.Service
    ): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(
    result,
    events,
    activityCenterService,
    contactsService,
    messageService,
    chatService,
    communityService
  )
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("activityCenterModule", self.viewVariant)
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.activityCenterDidLoad()

method hasMoreToShow*(self: Module): bool =
  self.controller.hasMoreToShow()

method unreadActivityCenterNotificationsCount*(self: Module): int =
  self.controller.unreadActivityCenterNotificationsCount()

method hasUnseenActivityCenterNotifications*(self: Module): bool =
  self.controller.hasUnseenActivityCenterNotifications()

method onNotificationsCountMayHaveChanged*(self: Module) =
  self.view.unreadActivityCenterNotificationsCountChanged()
  self.view.hasUnseenActivityCenterNotificationsChanged()

method hasUnseenActivityCenterNotificationsChanged*(self: Module) =
  self.view.hasUnseenActivityCenterNotificationsChanged()

proc createMessageItemFromDto(self: Module, message: MessageDto, communityId: string, albumMessages: seq[MessageDto]): MessageItem =
  let contactDetails = self.controller.getContactDetails(message.`from`)
  let communityChats = self.controller.getCommunityById(communityId).chats

  var quotedMessageAuthorDetails = ContactDetails()
  if message.quotedMessage.`from` != "":
    if(message.`from` == message.quotedMessage.`from`):
      quotedMessageAuthorDetails = contactDetails
    else:
      quotedMessageAuthorDetails = self.controller.getContactDetails(message.quotedMessage.`from`)

  var imagesAlbum: seq[string]
  var albumMessageIds: seq[string]
  if message.albumId != "":
    for msg in albumMessages:
      imagesAlbum.add(msg.image)
      albumMessageIds.add(msg.id)

  return msg_item_qobj.newMessageItem(msg_item.initItem(
    message.id,
    communityId, # we don't received community id via `activityCenterNotifications` api call
    message.chatId,
    message.responseTo,
    message.`from`,
    contactDetails.defaultDisplayName,
    contactDetails.optionalName,
    contactDetails.icon,
    contactDetails.colorHash,
    contactDetails.isCurrentUser,
    contactDetails.dto.added,
    message.outgoingStatus,
    self.controller.getRenderedText(message.parsedText, communityChats),
    self.controller.replacePubKeysWithDisplayNames(message.text),
    message.parsedText,
    message.image,
    message.containsContactMentions(),
    message.seen,
    timestamp = message.timestamp,
    clock = message.clock,
    message.contentType,
    message.messageType,
    message.contactRequestState,
    message.sticker.url,
    message.sticker.pack,
    message.links,
    message.linkPreviews,
    newTransactionParametersItem("","","","","","",-1,""),
    message.mentionedUsersPks,
    contactDetails.dto.trustStatus,
    contactDetails.dto.ensVerified,
    message.discordMessage,
    resendError = "",
    message.deleted,
    message.deletedBy,
    deletedByContactDetails = ContactDetails(),
    message.mentioned,
    message.quotedMessage.`from`,
    message.quotedMessage.text,
    self.controller.getRenderedText(message.quotedMessage.parsedText, communityChats),
    message.quotedMessage.contentType,
    message.quotedMessage.deleted,
    message.quotedMessage.discordMessage,
    quotedMessageAuthorDetails,
    message.quotedMessage.albumImages,
    message.quotedMessage.albumImagesCount,
    message.albumId,
    imagesAlbum,
    albumMessageIds,
    message.albumImagesCount,
    message.bridgeMessage,
    message.quotedMessage.bridgeMessage,
    ))

method convertToItems*(
    self: Module,
    activityCenterNotifications: seq[ActivityCenterNotificationDto]
    ): seq[notification_item.Item] =
  result = activityCenterNotifications.map(
    proc(notification: ActivityCenterNotificationDto): notification_item.Item =
      var messageItem: MessageItem
      var repliedMessageItem: MessageItem
      # default section id is `Chat` section
      let sectionId = if notification.communityId.len > 0:
          notification.communityId
        else:
          singletonInstance.userProfile.getPubKey()

      if (notification.message.id != ""):
        let communityId = sectionId
        # If there is a message in the Notification, transfer it to a MessageItem (QObject)
        messageItem = self.createMessageItemFromDto(notification.message, communityId, notification.albumMessages)

        if (notification.notificationType == ActivityCenterNotificationType.Reply and notification.message.responseTo != ""):
          repliedMessageItem = self.createMessageItemFromDto(notification.replyMessage, communityId, @[])

        if (notification.notificationType == ActivityCenterNotificationType.ContactVerification):
          repliedMessageItem = self.createMessageItemFromDto(notification.replyMessage, communityId, @[])

      var tokenDataItem = token_data_item.newTokenDataItem(
          notification.tokenData.chainId,
          notification.tokenData.txHash,
          notification.tokenData.walletAddress,
          notification.tokenData.isFirst,
          notification.tokenData.communiyId,
          notification.tokenData.amount,
          notification.tokenData.name,
          notification.tokenData.symbol,
          notification.tokenData.imageUrl,
          notification.tokenData.tokenType
      )

      let chatDetails = self.controller.getChatDetails(notification.chatId)

      return notification_item.initItem(
        notification.id,
        notification.chatId,
        notification.communityId,
        notification.membershipStatus,
        notification.verificationStatus,
        sectionId,
        notification.name,
        notification.author,
        notification.notificationType,
        notification.timestamp,
        notification.read,
        notification.dismissed,
        notification.accepted,
        messageItem,
        repliedMessageItem,
        chatDetails.chatType,
        tokenDataItem
      )
    )

method fetchActivityCenterNotifications*(self: Module) =
  self.controller.asyncActivityNotificationLoad()

method markAllActivityCenterNotificationsRead*(self: Module): string =
  self.controller.markAllActivityCenterNotificationsRead()

method markAllActivityCenterNotificationsReadDone*(self: Module) =
  self.view.markAllActivityCenterNotificationsReadDone()
  self.view.unreadActivityCenterNotificationsCountChanged()

method markActivityCenterNotificationRead*(self: Module, notificationId: string) =
  self.controller.markActivityCenterNotificationRead(notificationId)

method markActivityCenterNotificationReadDone*(self: Module, notificationIds: seq[string]) =
  for notificationId in notificationIds:
    self.view.markActivityCenterNotificationReadDone(notificationId)
  self.view.unreadActivityCenterNotificationsCountChanged()

method markAsSeenActivityCenterNotifications*(self: Module) =
  self.controller.markAsSeenActivityCenterNotifications()

method addActivityCenterNotifications*(self: Module, activityCenterNotifications: seq[ActivityCenterNotificationDto]) =
  self.view.addActivityCenterNotifications(self.convertToItems(activityCenterNotifications))
  self.view.hasUnseenActivityCenterNotificationsChanged()

method resetActivityCenterNotifications*(self: Module, activityCenterNotifications: seq[ActivityCenterNotificationDto]) =
  self.view.resetActivityCenterNotifications(self.convertToItems(activityCenterNotifications))

method markActivityCenterNotificationUnread*(self: Module, notificationId: string) =
  self.controller.markActivityCenterNotificationUnread(notificationId)

method acceptActivityCenterNotification*(self: Module, notificationId: string) =
  self.controller.acceptActivityCenterNotification(notificationId)

method dismissActivityCenterNotification*(self: Module, notificationId: string) =
  self.controller.dismissActivityCenterNotification(notificationId)

method acceptActivityCenterNotificationDone*(self: Module, notificationId: string) =
  self.view.acceptActivityCenterNotificationDone(notificationId)

method dismissActivityCenterNotificationDone*(self: Module, notificationId: string) =
  self.view.dismissActivityCenterNotificationDone(notificationId)

method markActivityCenterNotificationUnreadDone*(self: Module, notificationIds: seq[string]) =
  for notificationId in notificationIds:
    self.view.markActivityCenterNotificationUnreadDone(notificationId)
  self.view.unreadActivityCenterNotificationsCountChanged()

method removeActivityCenterNotifications*(self: Module, notificationIds: seq[string]) =
  self.view.removeActivityCenterNotifications(notificationIds)

method switchTo*(self: Module, sectionId, chatId, messageId: string) =
  self.controller.switchTo(sectionId, chatId, messageId)

method getDetails*(self: Module, sectionId: string, chatId: string): string =
  let groups = self.controller.getChannelGroups()
  var jsonObject = newJObject()

  for g in groups:
    if(g.id != sectionId):
      continue

    jsonObject["sType"] = %* g.channelGroupType
    jsonObject["sName"] = %* g.name
    jsonObject["sImage"] = %* g.images.thumbnail
    jsonObject["sColor"] = %* g.color

    for c in g.chats:
      if(c.id != chatId):
        continue

      var chatName = c.name
      var chatImage = c.icon
      if(c.chatType == ChatType.OneToOne):
        (chatName, chatImage) = self.controller.getOneToOneChatNameAndImage(c.id)

      jsonObject["cName"] = %* chatName
      jsonObject["cImage"] = %* chatImage
      jsonObject["cColor"] = %* c.color
      jsonObject["cEmoji"] = %* c.emoji
      return $jsonObject

method getChatDetailsAsJson*(self: Module, chatId: string): string =
  let chatDto = self.controller.getChatDetails(chatId)
  var jsonObject = newJObject()
  jsonObject["name"] = %* chatDto.name
  jsonObject["icon"] = %* chatDto.icon
  jsonObject["color"] = %* chatDto.color
  jsonObject["emoji"] = %* chatDto.emoji
  return $jsonObject

method setActiveNotificationGroup*(self: Module, group: int) =
  self.controller.setActiveNotificationGroup(ActivityCenterGroup(group))

method getActiveNotificationGroup*(self: Module): int =
  return self.controller.getActiveNotificationGroup().int

method setActivityCenterReadType*(self: Module, readType: int) =
  self.controller.setActivityCenterReadType(ActivityCenterReadType(readType))

method getActivityCenterReadType*(self: Module): int =
  return self.controller.getActivityCenterReadType().int

method setActivityGroupCounters*(self: Module, counters: Table[ActivityCenterGroup, int]) =
  self.view.setActivityGroupCounters(counters)
