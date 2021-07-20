import os

proc setup*(self: QGuiApplication) =
  ## Setup a new QGuiApplication
  dos_qguiapplication_create()
  self.deleted = false

proc delete*(self: QGuiApplication) =
  ## Delete the given QGuiApplication
  if self.deleted:
    return
  debugMsg("QGuiApplication", "delete")
  dos_qguiapplication_delete()
  self.deleted = true

proc icon*(application: QGuiApplication, filename: string) =
  dos_qguiapplication_icon(filename.cstring)

proc installEventFilter*(application: QGuiApplication, engine: QQmlApplicationEngine) =
  dos_qguiapplication_installEventFilter(engine.vptr)

proc newQGuiApplication*(): QGuiApplication =
  ## Return a new QGuiApplication
  new(result, delete)
  result.setup()

proc exec*(self: QGuiApplication) =
  ## Start the Qt event loop
  dos_qguiapplication_exec()

proc quit*(self: QGuiApplication) =
  ## Quit the Qt event loop
  dos_qguiapplication_quit()
