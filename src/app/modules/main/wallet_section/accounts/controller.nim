import sugar, sequtils, tables
import io_interface
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/network/service as network_service
import ../../../../../app_service/service/currency/service as currency_service
import ../../../../../app_service/service/currency/dto as currency_dto

import ../../../../global/global_singleton
import ../../../shared_modules/keycard_popup/io_interface as keycard_shared_module

import ../../../../core/eventemitter

const UNIQUE_WALLET_SECTION_ACCOUNTS_MODULE_AUTH_IDENTIFIER* = "WalletSection-AccountsModule-Authentication"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    walletAccountService: wallet_account_service.Service
    networkService: network_service.Service
    currencyService: currency_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  events: EventEmitter,
  walletAccountService: wallet_account_service.Service,
  networkService: network_service.Service,
  currencyService: currency_service.Service,
): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.walletAccountService = walletAccountService
  result.networkService = networkService
  result.currencyService = currencyService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_USER_AUTHENTICATED) do(e: Args):
    let args = SharedKeycarModuleArgs(e)
    if args.uniqueIdentifier != UNIQUE_WALLET_SECTION_ACCOUNTS_MODULE_AUTH_IDENTIFIER:
      return
    self.delegate.onUserAuthenticated(args.pin, args.password, args.keyUid)

proc getWalletAccounts*(self: Controller): seq[wallet_account_service.WalletAccountDto] =
  return self.walletAccountService.getWalletAccounts()

proc deleteAccount*(self: Controller, address: string, password = "", doPasswordHashing = false) =
  self.walletAccountService.deleteAccount(address, password, doPasswordHashing)

proc authenticateKeyPair*(self: Controller, keyUid = "") =
  let data = SharedKeycarModuleAuthenticationArgs(uniqueIdentifier: UNIQUE_WALLET_SECTION_ACCOUNTS_MODULE_AUTH_IDENTIFIER,
    keyUid: keyUid)
  self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER, data)

proc getAllMigratedKeyPairs*(self: Controller): seq[KeyPairDto] =
  return self.walletAccountService.getAllMigratedKeyPairs()

proc getChainIds*(self: Controller): seq[int] = 
  return self.networkService.getNetworks().map(n => n.chainId)

proc getEnabledChainIds*(self: Controller): seq[int] = 
  return self.networkService.getNetworks().filter(n => n.enabled).map(n => n.chainId)

proc getCurrentCurrency*(self: Controller): string =
  return self.walletAccountService.getCurrency()

proc getCurrencyFormat*(self: Controller, symbol: string): CurrencyFormatDto =
  return self.currencyService.getCurrencyFormat(symbol)

proc getMigratedKeyPairByKeyUid*(self: Controller, keyUid: string): seq[KeyPairDto] =
  return self.walletAccountService.getMigratedKeyPairByKeyUid(keyUid)

proc getWalletAccount*(self: Controller, address: string): WalletAccountDto =
  return self.walletAccountService.getAccountByAddress(address)
