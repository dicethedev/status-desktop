import ./io_interface, ./view, ./controller
import ../../../../../app_service/service/transaction/service as transaction_service

export io_interface

type 
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    view: View
    controller: controller.AccessInterface
    moduleLoaded: bool

proc newModule*[T](delegate: T, transactionService: transaction_service.ServiceInterface): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = newView(result)
  result.controller = controller.newController[Module[T]](result, transactionService)
  result.moduleLoaded = false

method delete*[T](self: Module[T]) =
  self.view.delete
  self.controller.delete

method load*[T](self: Module[T]) =
  self.moduleLoaded = true

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded
