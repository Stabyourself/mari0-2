local MapOptionsWindow = class("MapOptionsWindow")

MapOptionsWindow.x = 14
MapOptionsWindow.y = 14
MapOptionsWindow.width = 200
MapOptionsWindow.height = 120

function MapOptionsWindow:initialize(editor)
    self.editor = editor
    self.level = self.editor.level

    self.element = Gui3.Box:new(self.x, self.y, self.width, self.height)
    self.element:setDraggable(true)
    self.element.resizeable = true
    self.element.closeable = true
    self.element.scrollable = {true, true}
    self.element.title = "map options"
    self.editor.canvas:addChild(self.element)

    self.element.background = {0.5, 0.5, 0.5}

    self.element:addChild(Gui3.TextInput:new(self.x, self.y, 8, 1))
end

return MapOptionsWindow
