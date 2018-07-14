local MinimapWindow = class("MinimapWindow")

MinimapWindow.x = 14
MinimapWindow.y = 14
MinimapWindow.width = 300
MinimapWindow.height = 105

MinimapWindow.scale = 3
MinimapWindow.borderWidth = 3

function MinimapWindow:initialize(editor)
    self.editor = editor
    self.level = self.editor.level

    local height = 16 + self.editor.minimapImg:getHeight()*self.scale

    if self.editor.minimapImg:getWidth()*self.scale > self.width then -- accomodate the scrollbar
        height = height + 8
    end

    self.element = Gui3.Box:new(self.x, self.y, self.width, height)
    self.element.draggable = true
    self.element.resizeable = true
    self.element.closeable = true
    self.element.scrollable = {true, true}
    self.element.title = "minimap"
    self.element.clip = true
    self.editor.canvas:addChild(self.element)

    self.element.background = self.editor.checkerboardImg

    self.minimapDraw = Gui3.SubDraw:new(function() self.editor:drawMinimap() end, 0, 0, self.editor.minimapImg:getWidth()*self.scale, self.editor.minimapImg:getHeight()*self.scale)
    self.minimapDraw.hookmousepressed = function(...) self.editor:clickMinimap(...) end

    self.element:addChild(self.minimapDraw)
end

return MinimapWindow
