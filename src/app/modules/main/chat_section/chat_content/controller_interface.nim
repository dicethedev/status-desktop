import ../../../../../app_service/service/contacts/dto/[contacts]
import ../../../../../app_service/service/message/dto/[message, reaction]
import ../../../../../app_service/service/chat/dto/[chat]
import ../../../../../app_service/service/contacts/service

type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getMyChatId*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getChatDetails*(self: AccessInterface): ChatDto {.base.} =
  raise newException(ValueError, "No implementation available")

method getOneToOneChatNameAndImage*(self: AccessInterface): tuple[name: string, image: string, isIdenticon: bool] 
  {.base.} =
  raise newException(ValueError, "No implementation available")

method belongsToCommunity*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method unpinMessage*(self: AccessInterface, messageId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getMessageDetails*(self: AccessInterface, messageId: string): 
  tuple[message: MessageDto, reactions: seq[ReactionDto], error: string] {.base.} =
  raise newException(ValueError, "No implementation available")

method isUsersListAvailable*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getMyAddedContacts*(self: AccessInterface): seq[ContactsDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method unmuteChat*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getContactById*(self: AccessInterface, contactId: string): ContactsDto {.base.} =
  raise newException(ValueError, "No implementation available")

method getContactDetails*(self: AccessInterface, contactId: string): ContactDetails {.base.} =
  raise newException(ValueError, "No implementation available")