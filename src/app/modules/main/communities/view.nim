import NimQml, json, strutils, json_serialization, sequtils

import ./io_interface
import ../../shared_models/section_model
import ../../shared_models/section_item
import ../../shared_models/active_section
import ./models/curated_community_model
import ./models/curated_community_item
import ./models/discord_file_list_model
import ./models/discord_file_item
import ./models/discord_categories_model
import ./models/discord_category_item
import ./models/discord_channels_model
import ./models/discord_channel_item

QtObject:
  type
    View* = ref object of QObject
      communityTags: QVariant
      delegate: io_interface.AccessInterface
      model: SectionModel
      modelVariant: QVariant
      observedItem: ActiveSection
      curatedCommunitiesModel: CuratedCommunityModel
      curatedCommunitiesModelVariant: QVariant
      discordFileListModel: DiscordFileListModel
      discordFileListModelVariant: QVariant
      discordCategoriesModel: DiscordCategoriesModel
      discordCategoriesModelVariant: QVariant
      discordChannelsModel: DiscordChannelsModel
      discordChannelsModelVariant: QVariant
      discordOldestMessageTimestamp: QVariant

  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.observedItem.delete
    self.curatedCommunitiesModel.delete
    self.curatedCommunitiesModelVariant.delete
    self.discordFileListModel.delete
    self.discordFileListModelVariant.delete
    self.discordCategoriesModel.delete
    self.discordCategoriesModelVariant.delete
    self.discordChannelsModel.delete
    self.discordChannelsModelVariant.delete
    self.discordOldestMessageTimestamp.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.communityTags = newQVariant("")
    result.delegate = delegate
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)
    result.curatedCommunitiesModel = newCuratedCommunityModel()
    result.curatedCommunitiesModelVariant = newQVariant(result.curatedCommunitiesModel)
    result.discordFileListModel = newDiscordFileListModel()
    result.discordFileListModelVariant = newQVariant(result.discordFileListModel)
    result.discordCategoriesModel = newDiscordCategoriesModel()
    result.discordCategoriesModelVariant = newQVariant(result.discordCategoriesModel)
    result.discordChannelsModel = newDiscordChannelsModel()
    result.discordChannelsModelVariant = newQVariant(result.discordChannelsModel)
    result.discordOldestMessageTimestamp = newQVariant(0)
    result.observedItem = newActiveSection()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc communityAdded*(self: View, communityId: string) {.signal.}
  proc communityChanged*(self: View, communityId: string) {.signal.}
  proc discordOldestMessageTimestampChanged*(self: View) {.signal.}

  proc setCommunityTags*(self: View, communityTags: string) =
    self.communityTags = newQVariant(communityTags)

  proc setDiscordOldestMessageTimestamp*(self: View, timestamp: int) {.slot.} =
    self.discordOldestMessageTimestamp = newQVariant(timestamp)
    self.discordOldestMessageTimestampChanged()

  proc getDiscordOldestMessageTimestamp*(self: View): QVariant {.slot.} =
    return self.discordOldestMessageTimestamp

  QtProperty[QVariant] discordOldestMessageTimestamp:
    read = getDiscordOldestMessageTimestamp
    notify = discordOldestMessageTimestampChanged

  proc addItem*(self: View, item: SectionItem) =
    self.model.addItem(item)
    self.communityAdded(item.id)

  proc model*(self: View): SectionModel =
    result = self.model

  proc getTags(self: View): QVariant {.slot.} =
    return self.communityTags

  QtProperty[QVariant] tags:
    read = getTags

  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant

  QtProperty[QVariant] model:
    read = getModel

  proc curatedCommunitiesModel*(self: View): CuratedCommunityModel =
    result = self.curatedCommunitiesModel

  proc getCuratedCommunitiesModel(self: View): QVariant {.slot.} =
    return self.curatedCommunitiesModelVariant

  QtProperty[QVariant] curatedCommunities:
    read = getCuratedCommunitiesModel

  proc discordFileListModel*(self: View): DiscordFileListModel =
    result = self.discordFileListModel

  proc getDiscordFileListModel(self: View): QVariant{.slot.} =
    return self.discordFileListModelVariant

  QtProperty[QVariant] discordFileList:
    read = getDiscordFileListModel

  proc discordCategoriesModel*(self: View): DiscordCategoriesModel =
    result = self.discordCategoriesModel

  proc getDiscordCategoriesModel*(self: View): QVariant {.slot.} =
    return self.discordCategoriesModelVariant

  QtProperty[QVariant] discordCategories:
    read = getDiscordCategoriesModel

  proc discordChannelsModel*(self: View): DiscordChannelsModel =
    result = self.discordChannelsModel

  proc getDiscordChannelsModel*(self: View): QVariant {.slot.} =
    return self.discordChannelsModelVariant

  QtProperty[QVariant] discordChannels:
    read = getDiscordChannelsModel


  proc observedItemChanged*(self:View) {.signal.}

  proc getObservedItem(self: View): QVariant {.slot.} =
    return newQVariant(self.observedItem)

  QtProperty[QVariant] observedCommunity:
    read = getObservedItem
    notify = observedItemChanged

  proc setObservedCommunity*(self: View, itemId: string) {.slot.} =
    let item = self.model.getItemById(itemId)
    if (item.id == ""):
      return
    self.observedItem.setActiveSectionData(item)
    self.observedItemChanged()

  proc joinCommunity*(self: View, communityId: string, ensName: string) {.slot.} =
    # Users always have to request to join a community but might 
    # get automatically accepted.
    self.delegate.requestToJoinCommunity(communityId, ensName)

  proc createCommunity*(self: View, name: string,
                        description: string, introMessage: string, outroMessage: string,
                        access: int, color: string, tags: string,
                        imagePath: string,
                        aX: int, aY: int, bX: int, bY: int,
                        historyArchiveSupportEnabled: bool,
                        pinMessageAllMembersEnabled: bool) {.slot.} =
    self.delegate.createCommunity(name, description, introMessage, outroMessage, access, color, tags,
                                  imagePath, aX, aY, bX, bY, historyArchiveSupportEnabled, pinMessageAllMembersEnabled)

  proc deleteCommunityCategory*(self: View, communityId: string, categoryId: string): string {.slot.} =
    self.delegate.deleteCommunityCategory(communityId, categoryId)

  proc reorderCommunityCategories*(self: View, communityId: string, categoryId: string, position: int) {.slot} =
    self.delegate.reorderCommunityCategories(communityId, categoryId, position)

  proc reorderCommunityChannel*(self: View, communityId: string, categoryId: string, chatId: string, position: int): string {.slot} =
    self.delegate.reorderCommunityChannel(communityId, categoryId, chatId, position)

  proc requestToJoinCommunity*(self: View, communityId: string, ensName: string) {.slot.} =
    self.delegate.requestToJoinCommunity(communityId, ensName)

  proc requestCommunityInfo*(self: View, communityId: string) {.slot.} =
    self.delegate.requestCommunityInfo(communityId)

  proc isUserMemberOfCommunity*(self: View, communityId: string): bool {.slot.} =
    self.delegate.isUserMemberOfCommunity(communityId)

  proc userCanJoin*(self: View, communityId: string): bool {.slot.} =
    self.delegate.userCanJoin(communityId)

  proc isCommunityRequestPending*(self: View, communityId: string): bool {.slot.} =
    self.delegate.isCommunityRequestPending(communityId)

  proc deleteCommunityChat*(self: View, communityId: string, channelId: string) {.slot.} =
    self.delegate.deleteCommunityChat(communityId, channelId)

  proc importCommunity*(self: View, communityKey: string) {.slot.} =
    self.delegate.importCommunity(communityKey)

  proc importingCommunityStateChanged*(self:View, state: int, errorMsg: string) {.signal.}
  proc emitImportingCommunityStateChangedSignal*(self: View, state: int, errorMsg: string) =
    self.importingCommunityStateChanged(state, errorMsg)

  proc isMemberOfCommunity*(self: View, communityId: string, pubKey: string): bool {.slot.} =
    let sectionItem = self.model.getItemById(communityId)
    if (section_item.id == ""):
       return false
    return sectionItem.hasMember(pubKey)

  proc setFileListItems*(self: View, filePaths: string) {.slot.} =
    let filePaths = filePaths.split(',')
    var fileItems: seq[DiscordFileItem] = @[]

    for filePath in filePaths:
      var fileItem = DiscordFileItem()
      fileItem.filePath = filePath
      fileItem.errorMessage = ""
      fileItem.errorCode = 0
      fileItem.selected = true
      fileItem.validated = false
      fileItems.add(fileItem)
    self.discordFileListModel.setItems(fileItems)

  proc clearFileList*(self: View) {.slot.} =
    self.discordFileListModel.clearItems()

  proc requestExtractDiscordChannelsAndCategories*(self: View) {.slot.} =
    let filePaths = self.discordFileListModel.getSelectedFilePaths()
    self.delegate.requestExtractDiscordChannelsAndCategories(filePaths)

  proc selectDiscordCategory*(self: View, id: string) {.slot.} =
    self.discordCategoriesModel.selectItem(id)
    self.discordChannelsModel.selectItemsByCategoryId(id)

  proc unselectDiscordCategory*(self: View, id: string) {.slot.} =
    self.discordCategoriesModel.unselectItem(id)
    self.discordChannelsModel.unselectItemsByCategoryId(id)

  proc selectDiscordChannel*(self: View, id: string) {.slot.} =
    self.discordChannelsModel.selectItem(id)
    let item = self.discordChannelsModel.getItem(id)
    self.discordCategoriesModel.selectItem(item.getCategoryId())

  proc unselectDiscordChannel*(self: View, id: string) {.slot.} =
    self.discordChannelsModel.unselectItem(id)
    let item = self.discordChannelsModel.getItem(id)
    if self.discordChannelsModel.allChannelsByCategoryUnselected(item.getCategoryId()):
      self.discordCategoriesModel.unselectItem(item.getCategoryId())

  proc clearDiscordCategoriesAndChannels*(self: View) {.slot.} =
    self.discordCategoriesModel.clearItems()
    self.discordChannelsModel.clearItems()

