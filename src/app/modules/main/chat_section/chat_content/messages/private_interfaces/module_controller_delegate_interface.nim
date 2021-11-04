import ../../../../../../../app_service/service/message/dto/[message, reaction]

method newMessagesLoaded*(self: AccessInterface, messages: seq[MessageDto], reactions: seq[ReactionDto]) {.base.} =
  raise newException(ValueError, "No implementation available") 

method onReactionAdded*(self: AccessInterface, messageId: string, emojiId: int, reactionId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onReactionRemoved*(self: AccessInterface, messageId: string, reactionId: string) {.base.} =
  raise newException(ValueError, "No implementation available")