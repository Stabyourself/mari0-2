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

function MinimapWindow:updateBorder(x, y, w, h)
    if not self.cameraBorder then
        self.cameraBorder = Gui3.Rectangle:new(x, y, w, h)
        self.cameraBorder.scale = 3
        self.cameraBorder.color = {255, 0, 0}
        self.mapCanvas:addChild(self.cameraBorder)
    else
        self.cameraBorder.x = x
        self.cameraBorder.y = y
        self.cameraBorder.w = w
        self.cameraBorder.h = h
    end
end

function MinimapWindow:updateImg(img)
    if not self.mapCanvas then -- first update; create elements
        self.mapCanvas = Gui3.Canvas:new(0, 0, img:getWidth()*self.scale+self.padding*2, img:getHeight()*self.scale+self.padding*2)
        self.element:addChild(self.mapCanvas)

        self.imageElement = Gui3.Image:new(self.editor.minimapImg, self.padding, self.padding, nil, self.scale)
        self.mapCanvas:addChild(self.imageElement)
    else -- not first; update elements
        self.mapCanvas.w = img:getWidth()*self.scale+self.padding*2
        self.mapCanvas.h = img:getHeight()*self.scale+self.padding*2

        self.imageElement.img = img
    end
end

return MinimapWindow
