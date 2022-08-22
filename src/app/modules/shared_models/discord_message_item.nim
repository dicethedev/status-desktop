import Nimqml, json, strformat, sugar, sequtils

import ../../../app_service/service/message/dto/message
import discord_message_attachment_item
import discord_message_attachments_model

QtObject:
  type
    DiscordMessageItem* = ref object of QObject
      id: string
      `type`: string
      timestamp: string
      timestampEdited: string
      content: string
      authorName: string
      authorAvatarUrl: string
      authorAvatarImageBase64: string
      attachmentsModel: DiscordMessageAttachmentsModel
      attachmentsModelVariant: QVariant

  proc setup(self: DiscordMessageItem) =
    self.QObject.setup

  proc delete*(self: DiscordMessageItem) =
    self.QObject.delete

  proc newDiscordMessageItem*(
      id: string,
      `type`: string,
      timestamp: string,
      timestampEdited: string,
      content: string,
      authorAvatarUrl: string,
      authorName: string,
      authorAvatarImageBase64: string,
      attachments: seq[DiscordMessageAttachment] = @[]
      ): DiscordMessageItem =
    new(result, delete)
    result.setup
    result.id = id
    result.type = type
    result.timestamp = timestamp
    result.timestampEdited = timestampEdited
    result.content = content
    result.authorAvatarUrl = authorAvatarUrl
    result.authorName = authorName
    result.authorAvatarImageBase64 = authorAvatarImageBase64
    result.attachmentsModel = newDiscordMessageAttachmentsModel()
    result.attachmentsModel.setItems(map(attachments, x => initDiscordMessageAttachmentItem(x.id, x.fileUrl, x.fileName, x.base64)))
    result.attachmentsModelVariant = newQVariant(result.attachmentsModel)

  proc `$`*(self: DiscordMessageItem): string =
    result = fmt"""DiscordMessageItem(
      id: {$self.id},
      type: {$self.type},
      timestamp: {$self.timestamp},
      timestampEdited: {$self.timestampEdited},
      content: {$self.content},
      authorAvatarUrl: {$self.authorAvatarUrl},
      authorAvatarImageBase64: {$self.authorAvatarImageBase64},
      )"""

  proc idChanged*(self: DiscordMessageItem) {.signal.}

  proc id*(self: DiscordMessageItem): string {.inline.} =
    self.id

  QtProperty[string] id:
    read = id
    notify = idChanged

  proc timestampChanged*(self: DiscordMessageItem) {.signal.}

  proc timestamp*(self: DiscordMessageItem): string {.inline.} =
    self.timestamp

  QtProperty[string] timestamp:
    read = timestamp
    notify = timestampChanged

  proc timestampEditedChanged*(self: DiscordMessageItem) {.signal.}

  proc timestampEdited*(self: DiscordMessageItem): string {.inline.} =
    self.timestampEdited

  QtProperty[string] timestampEdited:
    read = timestampEdited
    notify = timestampEditedChanged

  proc contentChanged*(self: DiscordMessageItem) {.signal.}

  proc content*(self: DiscordMessageItem): string {.inline.} =
    self.content

  QtProperty[string] content:
    read = content
    notify = contentChanged

  proc authoAvatarUrlChanged*(self: DiscordMessageItem) {.signal.}
  proc authorAvatarUrl*(self: DiscordMessageItem): string {.inline.} =
    self.authorAvatarUrl

  QtProperty[string] authorAvatarUrl:
    read = authorAvatarUrl
    notify = authorAvatarUrlChanged

  proc authorNameChanged*(self: DiscordMessageItem) {.signal.}
  proc authorName*(self: DiscordMessageItem): string {.inline.} =
    self.authorName

  QtProperty[string] authorName:
    read = authorName
    notify = authorNameChanged

  proc authorAvatarImageBase64Changed*(self: DiscordMessageItem) {.signal.}
  proc authorAvatarImageBase64*(self: DiscordMessageItem): string {.inline.} =
    self.authorAvatarImageBase64

  QtProperty[string] authorAvatarImageBase64:
    read = authorAvatarImageBase64
    notify = authorAvatarImageBase64Changed

  proc attachmentsModel*(self: DiscordMessageItem): DiscordMessageAttachmentsModel =
    return self.attachmentsModel

  proc getAttachmentsModel*(self: DiscordMessageItem): QVariant {.slot.} =
    return self.attachmentsModelVariant

  QtProperty[QVariant] attachments:
    read = getAttachmentsModel
