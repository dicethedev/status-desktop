import NimQml
import ../item

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available") 

method storePassword*(self: AccessInterface, password: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setActiveSection*(self: AccessInterface, item: Item) {.base.} =
  raise newException(ValueError, "No implementation available")

method getChatSectionModule*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method getCommunitySectionModule*(self: AccessInterface, communityId: string): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")