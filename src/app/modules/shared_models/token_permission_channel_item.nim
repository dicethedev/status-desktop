import strformat

type
  TokenPermissionChannelItem* = object
    itemId: string
    name: string
    isCategory: bool
    categoryId: string
    emoji: string
    color: string
    icon: string
    colorId: int

proc `$`*(self: TokenPermissionChannelItem): string =
  result = fmt"""TokenPermissionChannelItem(
    itemId: {self.itemId},
    name: {self.name},
    isCategory: {self.isCategory},
    categoryId: {self.categoryId},
    emoji: {self.emoji},
    color: {self.color},
    icon: {self.icon},
    colorId: {self.colorId}
    ]"""

proc initTokenPermissionChannelItem*(
  itemId: string,
  name: string,
  isCategory: bool,
  categoryId: string,
  emoji: string,
  color: string,
  icon: string,
  colorId: int
): TokenPermissionChannelItem =
  result.itemId = itemId
  result.name = name
  result.isCategory = isCategory
  result.categoryId = categoryId
  result.emoji = emoji
  result.color = color
  result.icon = icon
  result.colorId = colorId

proc getItemId*(self: TokenPermissionChannelItem): string =
  return self.itemId

proc getName*(self: TokenPermissionChannelItem): string =
  return self.name

proc getIsCategory*(self: TokenPermissionChannelItem): bool =
  return self.isCategory

proc getCategoryId*(self: TokenPermissionChannelItem): string =
  return self.categoryId

proc getEmoji*(self: TokenPermissionChannelItem): string =
  return self.emoji

proc getColor*(self: TokenPermissionChannelItem): string =
  return self.color

proc getIcon*(self: TokenPermissionChannelItem): string =
  return self.icon

proc getColorId*(self: TokenPermissionChannelItem): int =
  return self.colorId

