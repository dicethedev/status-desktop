import NimQml
import io_interface
import ../io_interface as delegate_interface
import view, controller, item
import ../../../../app/boot/global_singleton

import ../../../../app_service/service/accounts/service_interface as accounts_service

import eventemitter

export io_interface

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: controller.AccessInterface
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  accountsService: accounts_service.ServiceInterface): 
  Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, accountsService)
  result.moduleLoaded = false

  singletonInstance.engine.setRootContextProperty("loginModule", result.viewVariant)

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

proc extractImages(self: Module, account: AccountDto, thumbnailImage: var string,
  largeImage: var string) =
  for img in account.images:
    if(img.imgType == "thumbnail"):
      thumbnailImage = img.uri
    elif(img.imgType == "large"):
      largeImage = img.uri

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("loginModule", self.viewVariant)
  self.controller.init()
  self.view.load()

  let openedAccounts = self.controller.getOpenedAccounts()
  if(openedAccounts.len > 0):
    var items: seq[Item]
    for acc in openedAccounts:
      var thumbnailImage: string
      var largeImage: string
      self.extractImages(acc, thumbnailImage, largeImage)
      items.add(initItem(acc.name, acc.identicon, thumbnailImage, largeImage,
      acc.keyUid))

    self.view.setModelItems(items)

    # set the first account as slected one
    self.setSelectedAccount(items[0])

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.loginDidLoad()

method setSelectedAccount*(self: Module, item: Item) =
  self.controller.setSelectedAccountKeyUid(item.getKeyUid())
  self.view.setSelectedAccount(item)

method login*(self: Module, password: string) =
  self.controller.login(password)

method loginAccountError*(self: Module, error: string) =
  self.view.loginAccountError(error)