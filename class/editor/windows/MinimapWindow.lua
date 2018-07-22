local MinimapWindow = class("MinimapWindow")

MinimapWindow.x = 14
MinimapWindow.y = 14
MinimapWindow.width = 300

MinimapWindow.borderWidth = 3

function MinimapWindow:initialize(editor)
    self.editor = editor
    local scale = self.editor.minimapScale
    self.level = self.editor.level

    local height = 16 + self.editor.minimapImg:getHeight()*(scale/VAR("scale"))

    if self.editor.minimapImg:getWidth()*(scale/VAR("scale")) > self.width then -- accomodate the scrollbar
        height = height + 8
    end

    self.element = Gui3.Box:new(self.x, self.y, self.width, height)
    self.element:setDraggable(true)
    self.element.resizeable = true
    self.element.closeable = true
    self.element.scrollable = {true, true}
    self.element.title = "minimap"
    self.editor.canvas:addChild(self.element)

    self.element.background = self.editor.checkerboardImg

    self.minimapDraw = Gui3.SubDraw:new(function() self.editor:drawMinimap() end, 0, 0, self.editor.minimapImg:getWidth()*(scale/VAR("scale")), self.editor.minimapImg:getHeight()*(scale/VAR("scale")))
    self.minimapDraw.hookmousepressed = function(...) self.editor:clickMinimap(...) end

    self.element:addChild(self.minimapDraw)
    self.element:mouseRegionChanged()
end

return MinimapWindow
