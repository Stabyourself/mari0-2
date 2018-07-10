local MinimapWindow = class("MinimapWindow")

MinimapWindow.x = 14
MinimapWindow.y = 14
MinimapWindow.width = 300
MinimapWindow.height = 105

MinimapWindow.scale = 3
MinimapWindow.borderWidth = 3
MinimapWindow.padding = 0

function MinimapWindow:initialize(editor)
    self.editor = editor
    self.level = self.editor.level

    local height = 16 + self.editor.minimapImg:getHeight()*self.scale + self.padding*2

    if self.editor.minimapImg:getWidth()*self.scale > self.width then -- accomodate the scrollbar
        height = height + 8
    end

    self.element = Gui3.Box:new(self.x, self.y, self.width + self.padding*2, height)
    self.element.draggable = true
    self.element.resizeable = true
    self.element.closeable = true
    self.element.scrollable = {true, true}
    self.element.title = "minimap"
    self.element.clip = true
    self.editor.canvas:addChild(self.element)

    self.element.background = self.editor.checkerboardImg

    self.subDraw = Gui3.SubDraw:new(function() self.editor:drawMinimap() end, self.padding, self.padding, 100, 100)

    self.element:addChild(self.subDraw)
end

return MinimapWindow
