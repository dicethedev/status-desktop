import NimQml, sequtils, sugar, json, strutils

# import ./item
import ../../../../../app_service/service/contacts/dto/contacts
import ./model
import status/types/profile
import models/[contact_list]
import ./io_interface

# import status/types/[identity_image, profile]

import ../../../../../app_service/[main]
import ../../../../../app_service/tasks/[qt, threadpool]

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      modelVariant: QVariant
      contactToAdd*: ContactsDto
      accountKeyUID*: string

  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)
    result.contactToAdd = ContactsDto()

  proc setContactList*(self: View, contacts: seq[ContactsDto]) =
    self.model.setContactList(contacts)

  proc modelChanged*(self: View) {.signal.}

  proc getModel*(self: View): QVariant {.slot.} =
    return self.modelVariant

  QtProperty[QVariant] model:
    read = getModel
    notify = modelChanged

  proc contactToAddChanged*(self: View) {.signal.}

  proc getContactToAddUsername(self: View): QVariant {.slot.} =
    var username = self.contactToAdd.alias;

    if self.contactToAdd.ensVerified and self.contactToAdd.name != "":
      username = self.contactToAdd.name

    return newQVariant(username)

  QtProperty[QVariant] contactToAddUsername:
    read = getContactToAddUsername
    notify = contactToAddChanged

  proc getContactToAddPubKey(self: View): QVariant {.slot.} =
    # TODO cofirm that id is the pubKey
    return newQVariant(self.contactToAdd.id)

  QtProperty[QVariant] contactToAddPubKey:
    read = getContactToAddPubKey
    notify = contactToAddChanged  

  proc ensWasResolved*(self: View, resolvedPubKey: string) {.signal.}

  proc contactLookedUp*(self: View, id: string) {.slot.} =
    self.ensWasResolved(id)

    if id == "":
      self.contactToAddChanged()
      return

    let contact = self.delegate.getContact(id)

    if contact != nil and contact.id != "":
      self.contactToAdd = contact
    else:
      self.contactToAdd = ContactsDto(
        id: id,
        alias: self.delegate.generateAlias(id),
        ensVerified: false
      )

    self.contactToAddChanged()

  proc lookupContact*(self: View, value: string) {.slot.} =
    if value == "":
      return

    self.delegate.lookupContact(value)

  proc addContact*(self: View, publicKey: string) {.slot.} =
    self.delegate.addContact(publicKey)
    # TODO add back joining of timeline
    # self.status.chat.join(status_utils.getTimelineChatId(publicKey), ChatType.Profile, "", publicKey)

  proc rejectContactRequest*(self: View, publicKey: string) {.slot.} =
    self.delegate.rejectContactRequest(publicKey)

  proc rejectContactRequests*(self: View, publicKeysJSON: string) {.slot.} =
    let publicKeys = publicKeysJSON.parseJson
    for pubkey in publicKeys:
      self.rejectContactRequest(pubkey.getStr)

  proc acceptContactRequests*(self: View, publicKeysJSON: string) {.slot.} =
    let publicKeys = publicKeysJSON.parseJson
    for pubkey in publicKeys:
      self.addContact(pubkey.getStr)

  proc changeContactNickname*(self: View, publicKey: string, nickname: string) {.slot.} =
    var nicknameToSet = nickname
    if (nicknameToSet == ""):
      nicknameToSet = DELETE_CONTACT
    self.delegate.changeContactNickname(publicKey, nicknameToSet, self.accountKeyUID)

  proc unblockContact*(self: View, publicKey: string) {.slot.} =
    self.delegate.unblockContact(publicKey)

  proc contactBlocked*(self: View, publicKey: string) {.signal.}

  proc blockContact*(self: View, publicKey: string) {.slot.} =
    self.contactBlocked(publicKey)
    self.delegate.blockContact(publicKey)

  proc removeContact*(self: View, publicKey: string) {.slot.} =
    self.delegate.removeContact(publicKey)
    # TODO add back leaving timeline
    # let channelId = status_utils.getTimelineChatId(publicKey)
    # if self.status.chat.hasChannel(channelId):
    #   self.status.chat.leave(channelId)
