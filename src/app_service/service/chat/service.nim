import Tables, json, sequtils, strformat, chronicles

import service_interface, dto
import status/statusgo_backend_new/chat as status_go

export service_interface

logScope:
  topics = "chat-service"

type 
  Service* = ref object of ServiceInterface
    chats: Table[string, Dto] # [chat_id, Dto]

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()
  result.chats = initTable[string, Dto]()

method init*(self: Service) =
  try:
    let response = status_go.getChats()

    let chats = map(response.result.getElems(), 
    proc(x: JsonNode): Dto = x.toDto())

    for chat in chats:
      if chat.active and chat.chatType != ChatType.Unknown:
        self.chats[chat.id] = chat

  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return