local Box = class("Gui3.Box", Gui3.Element)

Box.movesToTheFront = true

function Box:initialize(x, y, w, h)
    Gui3.Element.initialize(self, x, y, w, h)

    self.background = {0, 0, 0, 0}
    self.backgroundQuad = love.graphics.newQuad(0, 0, 4, 4, 4, 4)
    
    self.children = {}
    
    self.posMin[1] = -3
    self.posMin[2] = -2
    
    self.posMax[1] = -3
    self.posMax[2] = -4
    
    self.childBox = {2, 3, self.w-4, self.h-6}
end

function Box:update(dt, x, y, mouseBlocked)
    local ret = Gui3.Element.update(self, dt, x, y, mouseBlocked)
    
    if self.draggable then
        self.sizeMin[1] = 19
        self.sizeMin[2] = 29

        self.childBox[1] = 3
        self.childBox[2] = 12
        self.childBox[3] = self.w-6
        self.childBox[4] = self.h-16
    else
        self.sizeMin[1] = 17
        self.sizeMin[2] = 19

        self.childBox[1] = 2
        self.childBox[2] = 3
        self.childBox[3] = self.w-4
        self.childBox[4] = self.h-6
    end

    return ret
end

function Box:draw(level)
    Gui3.Element.translate(self)
    
    if type(self.background) == "table" then
        love.graphics.setColor(self.background)
        love.graphics.rectangle("fill", self.childBox[1], self.childBox[2], self.childBox[3], self.childBox[4])
    elseif type(self.background) == "userdata" then
        self.backgroundQuad:setViewport(self.scroll[1]%4, self.scroll[2]%4, self.childBox[3], self.childBox[4])
        self.background:setWrap("repeat", "repeat")
            
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(self.background, self.backgroundQuad, self.childBox[1], self.childBox[2])
    end
    
    
    love.graphics.setColor(1, 1, 1)
    
    -- Border
    local img = self.gui.img.box
    local quad = Gui3.boxQuad
    if self.draggable then
        img = self.gui.img.boxTitled
        quad = Gui3.titledBoxQuad
    end
    
    Gui3.drawBox(img, quad, 0, 0, self.w, self.h)
    
    if self.title then
        fontOutlined:print(self.title, 3, 2)
    end
    
    if self.closeable then
        local img = self.gui.img.boxClose
        if self.closing then
            img = self.gui.img.boxCloseActive
        elseif self:closeCollision(self.mouse[1], self.mouse[2]) then
            img = self.gui.img.boxCloseHover
        end
        
        love.graphics.draw(img, self.w-12, 2)
    end
    
    Gui3.Element.draw(self, level)
    
    if self.resizeable then
        local img = self.gui.img.boxResize
        if self.resizing then
            img = self.gui.img.boxResizeActive
        elseif self:resizeCornerCollision(self.mouse[1], self.mouse[2]) then
            img = self.gui.img.boxResizeHover
        end
        
        local x, y = self.w-11, self.h-12
        if not self.draggable then
            x = x + 1
            y = y + 1
        end
        
        love.graphics.draw(img, x, y)
    end
    
    Gui3.Element.unTranslate(self)
end

function Box:titleBarCollision(x, y)
    return not self.mouseBlocked and x >= 0 and x < self.w and y >= 0 and y < 12
end

function Box:resizeCornerCollision(x, y)
    return not self.mouseBlocked and x >= self.w-11 and x < self.w-3 and y >= self.h-12 and y < self.h-4
end

function Box:closeCollision(x, y)
    return not self.mouseBlocked and x >= self.w-12 and x < self.w-3 and y >= 2 and y < 11
end

function Box:collision(x, y)
    return not self.mouseBlocked and x >= 0 and x < self.w and y >= 0 and y < self.h
end

function Box:mousepressed(x, y, button)
    -- Check resize before the rest because reasons
    if self.resizeable and self:resizeCornerCollision(x, y) then
        self.resizing = true
        self.resizePos[1] = self.w-x
        self.resizePos[2] = self.h-y

    elseif self.closeable and self:closeCollision(x, y) then
        self.closing = true
        
    elseif self.draggable and self:titleBarCollision(x, y) then
        self.dragging = true
        self.dragPos[1] = x
        self.dragPos[2] = y
        
    end
    
    return Gui3.Element.mousepressed(self, x, y, button)
end

function Box:mousereleased(x, y, button)
    self.dragging = false
    self.resizing = false
    
    if self.closing then
        if self:closeCollision(x, y) then
            self.parent:removeChild(self)
        else
            self.closing = false
        end
    end

    Gui3.Element.mousereleased(self, x, y, button)
end

return Box
