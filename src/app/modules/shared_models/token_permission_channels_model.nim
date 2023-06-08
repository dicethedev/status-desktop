import NimQml, Tables
import token_permission_channel_item

type
  ModelRole {.pure.} = enum
    ItemId = UserRole + 1
    Name
    IsCategory
    CategoryId
    Emoji
    Color
    Icon
    ColorId

QtObject:
  type TokenPermissionChannelsModel* = ref object of QAbstractListModel
    items*: seq[TokenPermissionChannelItem]

  proc setup(self: TokenPermissionChannelsModel) =
    self.QAbstractListModel.setup

  proc delete(self: TokenPermissionChannelsModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc newTokenPermissionChannelsModel*(): TokenPermissionChannelsModel =
    new(result, delete)
    result.setup

  method roleNames(self: TokenPermissionChannelsModel): Table[int, string] =
    {
      ModelRole.ItemId.int:"itemId",
      ModelRole.Name.int:"name",
      ModelRole.IsCategory.int:"isCategory",
      ModelRole.CategoryId.int:"categoryId",
      ModelRole.Emoji.int:"emoji",
      ModelRole.Color.int:"color",
      ModelRole.Icon.int:"icon",
      ModelRole.ColorId.int:"colorId",
    }.toTable

  proc countChanged(self: TokenPermissionChannelsModel) {.signal.}

  proc getCount(self: TokenPermissionChannelsModel): int {.slot.} =
    echo "GETTING COUNT: ", self.items.len
    return self.items.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: TokenPermissionChannelsModel, index: QModelIndex = nil): int =
    return self.items.len

  method data(self: TokenPermissionChannelsModel, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.items.len:
      return
    let item = self.items[index.row]
    let enumRole = role.ModelRole
    case enumRole:
      of ModelRole.ItemId:
        result = newQVariant(item.getItemId())
      of ModelRole.Name:
        result = newQVariant(item.getName())
      of ModelRole.IsCategory:
        result = newQVariant(item.getIsCategory())
      of ModelRole.CategoryId:
        result = newQVariant(item.getCategoryId())
      of ModelRole.Emoji:
        result = newQVariant(item.getEmoji())
      of ModelRole.Color:
        result = newQVariant(item.getColor())
      of ModelRole.Icon:
        result = newQVariant(item.getIcon())
      of ModelRole.ColorId:
        result = newQVariant(item.getColorId())

  proc addItem*(self: TokenPermissionChannelsModel, item: TokenPermissionChannelItem) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()
    self.countChanged()

  proc setItems*(self: TokenPermissionChannelsModel, items: seq[TokenPermissionChannelItem]) =
    echo "SETTING COUNT: ", items.len
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()
