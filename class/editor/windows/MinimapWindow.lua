local MinimapWindow = class("MinimapWindow")

MinimapWindow.x = 14
MinimapWindow.y = 14
MinimapWindow.width = 300
MinimapWindow.height = 105

function MinimapWindow:initialize(editor)
    self.editor = editor
    self.level = self.editor.level

    local height = 16 + self.editor.minimapImg:getHeight()*3

    if self.editor.minimapImg:getWidth()*3 > self.width then -- accomodate the scrollbar
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

    self.imageElement = Gui3.Image:new(self.editor.minimapImg, 0, 0, nil, 3)

    self.element:addChild(self.imageElement)

    self.buttons = {}
end

function MinimapWindow:updateImg(img)
    self.imageElement.img = img
end

return MinimapWindow
