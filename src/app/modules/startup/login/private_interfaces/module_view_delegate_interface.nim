import ../item

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method setSelectedAccount*(self: AccessInterface, item: Item) {.base.} =
  raise newException(ValueError, "No implementation available")