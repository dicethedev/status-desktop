import NimQml, json, sequtils, sugar, tables, strutils

import ./io_interface
import ../io_interface as delegate_interface
import ./view, ./controller
import ./models/curated_community_item
import ./models/curated_community_model
import ./models/discord_category_item
import ./models/discord_categories_model
import ./models/discord_channel_item
import ./models/discord_channels_model
import ./models/discord_file_list_model
import ./models/discord_import_task_item
import ./models/discord_import_tasks_model
import ./models/discord_import_error_item
import ./models/discord_import_errors_model
import ../../shared_models/section_item
import ../../shared_models/[member_item, member_model, section_model]
import ../../../global/global_singleton
import ../../../core/eventemitter
import ../../../../app_service/service/community/service as community_service
import ../../../../app_service/service/contacts/service as contacts_service
import ../../../../app_service/service/chat/dto/chat

export io_interface

type
  ImportCommunityState {.pure.} = enum
    Imported = 0
    ImportingInProgress
    ImportingError

type
  Module*  = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: Controller
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

# Forward declaration
method setCommunityTags*(self: Module, communityTags: string)
method setAllCommunities*(self: Module, communities: seq[CommunityDto])
method setCuratedCommunities*(self: Module, curatedCommunities: seq[CuratedCommunity])

proc newModule*(
    delegate: delegate_interface.AccessInterface,
    events: EventEmitter,
    communityService: community_service.Service,
    contactsService: contacts_service.Service): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(
    result,
    events,
    communityService,
    contactsService,
  )
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("communitiesModule", self.viewVariant)
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true

  self.setCommunityTags(self.controller.getCommunityTags())
  self.setAllCommunities(self.controller.getAllCommunities())
  self.setCuratedCommunities(self.controller.getCuratedCommunities())

  self.delegate.communitiesModuleDidLoad()

method getCommunityItem(self: Module, c: CommunityDto): SectionItem =
  return initItem(
      c.id,
      SectionType.Community,
      c.name,
      c.admin,
      c.description,
      c.introMessage,
      c.outroMessage,
      c.images.thumbnail,
      c.images.banner,
      icon = "",
      c.color,
      c.tags,
      hasNotification = false,
      notificationsCount = 0,
      active = false,
      enabled = true,
      c.joined,
      c.canJoin,
      c.canManageUsers,
      c.canRequestAccess,
      c.isMember,
      c.permissions.access,
      c.permissions.ensOnly,
      c.muted, 
      c.members.map(proc(member: Member): MemberItem =
        let contactDetails = self.controller.getContactDetails(member.id)
        result = initMemberItem(
          pubKey = member.id,
          displayName = contactDetails.displayName,
          ensName = contactDetails.details.name,
          localNickname = contactDetails.details.localNickname,
          alias = contactDetails.details.alias,
          icon = contactDetails.icon,
          onlineStatus = toOnlineStatus(self.controller.getStatusForContactWithId(member.id).statusType),
          isContact = contactDetails.details.isContact,
          )),
      historyArchiveSupportEnabled = c.settings.historyArchiveSupportEnabled,
      bannedMembers = c.bannedMembersIds.map(proc(bannedMemberId: string): MemberItem =
        let contactDetails = self.controller.getContactDetails(bannedMemberId)
        result = initMemberItem(
          pubKey = bannedMemberId,
          displayName = contactDetails.displayName,
          ensName = contactDetails.details.name,
          localNickname = contactDetails.details.localNickname,
          alias = contactDetails.details.alias,
          icon = contactDetails.icon,
          onlineStatus = toOnlineStatus(self.controller.getStatusForContactWithId(bannedMemberId).statusType),
          isContact = contactDetails.details.added, # FIXME
        )
      ),
    )

method getCuratedCommunityItem(self: Module, c: CuratedCommunity): CuratedCommunityItem =
  return initCuratedCommunityItem(
      c.communityId,
      c.community.name,
      c.community.description,
      c.available,
      c.community.images.thumbnail,
      c.community.color,
      c.community.tags,
      len(c.community.members))

method getDiscordCategoryItem(self: Module, c: DiscordCategoryDto): DiscordCategoryItem =
  return initDiscordCategoryItem(
      c.id,
      c.name,
      true)

method getDiscordChannelItem(self: Module, c: DiscordChannelDto): DiscordChannelItem =
  return initDiscordChannelItem(
      c.id,
      c.categoryId,
      c.name,
      c.description,
      c.filePath,
      true)

method getDiscordImportTaskItem(self: Module, t: DiscordImportTaskProgress): DiscordImportTaskItem =

  var errorItems: seq[DiscordImportErrorItem] = @[]
  for error in t.errors:
    errorItems.add(initDiscordImportErrorItem(t.`type`, error.code, error.message))

  return initDiscordImportTaskItem(
      t.`type`,
      t.progress,
      errorItems)

method setCommunityTags*(self: Module, communityTags: string) =
  self.view.setCommunityTags(communityTags)

method setAllCommunities*(self: Module, communities: seq[CommunityDto]) =
  for community in communities:
    self.view.addItem(self.getCommunityItem(community))

method communityAdded*(self: Module, community: CommunityDto) =
  self.view.addItem(self.getCommunityItem(community))

method joinCommunity*(self: Module, communityId: string): string =
  self.controller.joinCommunity(communityId)

method communityEdited*(self: Module, community: CommunityDto) =
  self.view.model().editItem(self.getCommunityItem(community))
  self.view.communityChanged(community.id)

method setCuratedCommunities*(self: Module, curatedCommunities: seq[CuratedCommunity]) =
  for community in curatedCommunities:
    self.view.curatedCommunitiesModel().addItem(self.getCuratedCommunityItem(community))

method curatedCommunityAdded*(self: Module, community: CuratedCommunity) =
  self.view.curatedCommunitiesModel().addItem(self.getCuratedCommunityItem(community))

method curatedCommunityEdited*(self: Module, community: CuratedCommunity) =
  self.view.curatedCommunitiesModel().addItem(self.getCuratedCommunityItem(community))

method requestAdded*(self: Module) =
  # TODO to model or view
  discard

method communityLeft*(self: Module, communityId: string) =
   # TODO to model or view
  discard

method communityChannelReordered*(self: Module) =
   # TODO to model or view
  discard

method communityChannelDeleted*(self: Module, communityId: string, chatId: string) =
   # TODO to model or view
  discard

method communityCategoryCreated*(self: Module) =
   # TODO to model or view
  discard

method communityCategoryEdited*(self: Module) =
   # TODO to model or view
  discard

method communityCategoryDeleted*(self: Module) =
   # TODO to model or view
  discard

method createCommunity*(self: Module, name: string,
                        description, introMessage: string, outroMessage: string,
                        access: int, color: string, tags: string,
                        imagePath: string,
                        aX: int, aY: int, bX: int, bY: int,
                        historyArchiveSupportEnabled: bool,
                        pinMessageAllMembersEnabled: bool) =
  self.controller.createCommunity(name, description, introMessage, outroMessage, access, color, tags,
                                  imagePath, aX, aY, bX, bY, historyArchiveSupportEnabled, pinMessageAllMembersEnabled)

method importDiscordCommunity*(self: Module, name: string,
                        description, introMessage: string, outroMessage: string,
                        access: int, color: string, tags: string,
                        imagePath: string,
                        aX: int, aY: int, bX: int, bY: int,
                        historyArchiveSupportEnabled: bool,
                        pinMessageAllMembersEnabled: bool,
                        filesToImport: seq[string],
                        fromTimestamp: int) =
  self.controller.importDiscordCommunity(name, description, introMessage, outroMessage, access, color, tags,
                                  imagePath, aX, aY, bX, bY, historyArchiveSupportEnabled, pinMessageAllMembersEnabled, filesToImport, fromTimestamp)

method deleteCommunityCategory*(self: Module, communityId: string, categoryId: string) =
  self.controller.deleteCommunityCategory(communityId, categoryId)

method reorderCommunityCategories*(self: Module, communityId: string, categoryId: string, position: int) =
#   self.controller.reorderCommunityCategories(communityId, categoryId, position)
  discard

method communityMuted*(self: Module, communityId: string, muted: bool) =
  self.view.model().setMuted(communityId, muted)

method discordCategoriesAndChannelsExtracted*(self: Module, categories: seq[DiscordCategoryDto], channels: seq[DiscordChannelDto], oldestMessageTimestamp: int, errors: Table[string, DiscordImportError], errorsCount: int) =

  for filePath in errors.keys:
    self.view.discordFileListModel().updateErrorState(filePath, errors[filePath].message, errors[filePath].code)

  self.view.discordFileListModel().setAllValidated()

  self.view.discordCategoriesModel().clearItems()
  self.view.discordChannelsModel().clearItems()
  self.view.setDiscordOldestMessageTimestamp(oldestMessageTimestamp)

  for discordCategory in categories:
    self.view.discordCategoriesModel().addItem(self.getDiscordCategoryItem(discordCategory))
  for discordChannel in channels:
    self.view.discordChannelsModel().addItem(self.getDiscordChannelItem(discordChannel))

  self.view.setDiscordDataExtractionInProgress(false)
  self.view.setDiscordImportErrorsCount(errorsCount)
  self.view.discordChannelsModel().hasSelectedItemsChanged()

method discordImportProgressUpdated*(self: Module, communityId: string, tasks: seq[DiscordImportTaskProgress], progress: float, errorsCount: int, warningsCount: int, stopped: bool) =

  var taskItems: seq[DiscordImportTaskItem] = @[]

  for task in tasks:
    for error in task.errors:
      let errorItem = initDiscordImportErrorItem(task.`type`, error.code, error.message)
      self.view.discordImportErrorsModel().addItem(errorItem)
    taskItems.add(self.getDiscordImportTaskItem(task))

  self.view.discordImportTasksModel().setItems(taskItems)
  self.view.setDiscordImportErrorsCount(errorsCount)
  self.view.setDiscordImportWarningsCount(warningsCount)
  # For some reason, exposing the global `progress` as QtProperty[float]`
  # doesn't translate well into QML.
  # That's why we pass it as integer instead.
  self.view.setDiscordImportProgress((progress*100).int)
  self.view.setDiscordImportProgressStopped(stopped)

method requestToJoinCommunity*(self: Module, communityId: string, ensName: string) =
  self.controller.requestToJoinCommunity(communityId, ensName)

method requestCommunityInfo*(self: Module, communityId: string) =
  self.controller.requestCommunityInfo(communityId)

method isUserMemberOfCommunity*(self: Module, communityId: string): bool =
  self.controller.isUserMemberOfCommunity(communityId)

method userCanJoin*(self: Module, communityId: string): bool =
  self.controller.userCanJoin(communityId)

method isCommunityRequestPending*(self: Module, communityId: string): bool =
  self.controller.isCommunityRequestPending(communityId)

method deleteCommunityChat*(self: Module, communityId: string, channelId: string) =
  self.controller.deleteCommunityChat(communityId, channelId)

method communityImported*(self: Module, community: CommunityDto) =
  self.view.addItem(self.getCommunityItem(community))
  self.view.emitImportingCommunityStateChangedSignal(ImportCommunityState.Imported.int, "")

method importCommunity*(self: Module, communityKey: string) =
  self.view.emitImportingCommunityStateChangedSignal(ImportCommunityState.ImportingInProgress.int, "")
  self.controller.importCommunity(communityKey)

method onImportCommunityErrorOccured*(self: Module, error: string) =
  self.view.emitImportingCommunityStateChangedSignal(ImportCommunityState.ImportingError.int, error)

method requestExtractDiscordChannelsAndCategories*(self: Module, filesToImport: seq[string]) =
  self.view.setDiscordDataExtractionInProgress(true)
  self.controller.requestExtractDiscordChannelsAndCategories(filesToImport)
