local Box = class("GUI.Box", GUI.Element)

local boxQuad = {
    love.graphics.newQuad(0, 0, 16, 16, 33, 33),
    love.graphics.newQuad(16, 0, 1, 16, 33, 33),
    love.graphics.newQuad(17, 0, 16, 16, 33, 33),
    love.graphics.newQuad(0, 16, 16, 1, 33, 33),
    nil,
    love.graphics.newQuad(17, 16, 16, 1, 33, 33),
    love.graphics.newQuad(0, 17, 16, 16, 33, 33),
    love.graphics.newQuad(16, 17, 1, 16, 33, 33),
    love.graphics.newQuad(17, 17, 16, 16, 33, 33),
}

local scrollBarQuad = {
    love.graphics.newQuad(0, 0, 8, 8, 17, 8),
    love.graphics.newQuad(8, 0, 1, 8, 17, 8),
    love.graphics.newQuad(9, 0, 8, 8, 17, 8),
}

function Box:initialize(x, y, w, h)
    GUI.Element.initialize(self, x, y, w, h)
    
    self.scrollable = {false, false}
    self.scroll = {0, 0}
    self.backgroundColor = {0, 0, 0, 0}
    
    self.children = {}
end

function Box:update(dt)
    GUI.Element.update(self, dt)
    
    local titleHeight = 0
    
    if self.title then
        titleHeight = 10
    end
    
    if self.dragging then
        local x, y = self.parent:getMouse()
        
        self.x = x-self.dragX
        self.y = y-self.dragY
    end
    
    if self.resizing then
        local x, y = self.parent:getMouse()
        
        self.w = math.min(self.parent.w-self.x, x-self.x+self.resizeX)
        self.h = math.min(self.parent.h-self.y, y-self.y+self.resizeY)
    end
    
    --limit w and y
    self.w = math.max(8, self.w)
    self.w = math.min(self.parent.w, self.w)
    
    self.h = math.max(8, self.h)
    self.h = math.min(self.parent.h-titleHeight, self.h)
        
    --limit x and y
    self.x = math.max(0, self.x)
    self.x = math.min(self.parent.w-self.w, self.x)
    
    self.y = math.max(titleHeight, self.y)
    self.y = math.min(self.parent.h-self.h, self.y)
    
    local innerW, innerH = self:getInnerSize()
    
    if self.scrollingX then
        local x, y = self:getMouse()
        
        local factor = ((x-self.scrollingXdragX)/(self.w-25))
        
        factor = math.clamp(factor, 0, 1)
        self.scroll[1] = factor*(innerW-self.w)
    end
    
    self.scroll[1] = math.min(innerW-self.w, self.scroll[1])
    self.scroll[1] = math.max(0, self.scroll[1])
    
    print(self.scroll[1])
end

function Box:draw(level)
    GUI.Element.translate(self)
    
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", 0, 0, self.w, self.h)
    
    love.graphics.setColor(255, 255, 255)
    
    -- Border
    local img = self.gui.img.box
    if self.title then
        img = self.gui.img.boxTitled
    end
    
    love.graphics.draw(img, boxQuad[1], -16, -16)
    love.graphics.draw(img, boxQuad[2], 0, -16, 0, self.w, 1)
    love.graphics.draw(img, boxQuad[3], self.w, -16)
    love.graphics.draw(img, boxQuad[4], -16, 0, 0, 1, self.h)
    
    love.graphics.draw(img, boxQuad[6], self.w, y, 0, 1, self.h)
    love.graphics.draw(img, boxQuad[7], -16, self.h)
    love.graphics.draw(img, boxQuad[8], 0, self.h, 0, self.w, 1)
    love.graphics.draw(img, boxQuad[9], self.w, self.h)
    
    if self.title then
        love.graphics.stencil(function()
            love.graphics.rectangle("fill", 0, -10, self.w, 10)
        end, "increment", 1, true)
        love.graphics.setStencilTest("equal", level)
        
        marioPrint(self.title, 0, -10)
        
        love.graphics.stencil(function()
            love.graphics.rectangle("fill", 0, -10, self.w, 10)
        end, "decrement", 1, true)
        love.graphics.setStencilTest("equal", level-1)
    end
    
    if self.closeable then
        if self.closing then
            love.graphics.draw(self.gui.img.boxCloseActive, self.w-11, -13)
        elseif self:closeCollision(self:getMouse()) then
            love.graphics.draw(self.gui.img.boxCloseHover, self.w-11, -13)
        else
            love.graphics.draw(self.gui.img.boxClose, self.w-11, -13)
        end
    end
    
    GUI.Element.stencil(self, level)
    
    love.graphics.translate(-self.scroll[1], -self.scroll[2])
    
    GUI.Element.draw(self, level)
    
    love.graphics.translate(self.scroll[1], self.scroll[2])
    
    GUI.Element.unStencil(self, level)
    
    local innerW, innerH = self:getInnerSize()
    
    if self.scrollable[1] then
        if innerW > self.w then
            love.graphics.draw(self.gui.img.scrollBarBack, 0, self.h-8, 0, self.w, 1)
            
            local scrollbarX = self:getScrollBarX()
            
            local img = self.gui.img.scrollBar
            
            if self:scrollXCollision(self:getMouse()) or self.scrollingX then
                img = self.gui.img.scrollBarHover
            end
            
            love.graphics.draw(img, scrollBarQuad[1], scrollbarX, self.h-8)
            love.graphics.draw(img, scrollBarQuad[2], scrollbarX+8, self.h-8)
            love.graphics.draw(img, scrollBarQuad[3], scrollbarX+9, self.h-8)
        end
    end
    
    if self.resizeable then
        if self.resizing then
            love.graphics.draw(self.gui.img.boxResizeActive, self.w-11, self.h-11)
        elseif self:resizeCornerCollision(self:getMouse()) then
            love.graphics.draw(self.gui.img.boxResizeHover, self.w-11, self.h-11)
        else
            love.graphics.draw(self.gui.img.boxResize, self.w-11, self.h-11)
        end
    end
    
    GUI.Element.unTranslate(self)
end

function Box:getScrollBarX()
    local innerW, innerH = self:getInnerSize()
    
    return (self.scroll[1]/(innerW-self.w))*(self.w-25)
end

function Box:titleBarCollision(x, y)
    return x >= -2 and x < self.w+2 and y >= -10 and y < 0
end

function Box:resizeCornerCollision(x, y)
    return x >= self.w-8 and x < self.w+2 and y >= self.h-8 and y < self.h+2
end

function Box:closeCollision(x, y)
    return x >= self.w-8 and x < self.w+1 and y >= -9 and y < 0
end

function Box:collision(x, y)
    return x >= -2 and x < self.w+2 and y >= -2 and y < self.h+3
end

function Box:scrollXCollision(x, y)
    local scrollbarX = self:getScrollBarX()
    
    return x >= scrollbarX and x < scrollbarX + 17 and y >= self.h-8 and y < self.h
end

function Box:mousepressed(x, y, button)
    -- Check resize before the rest because reasons
    if self.resizeable and self:resizeCornerCollision(x, y) then
        self.resizing = true
        self.resizeX = self.w-x
        self.resizeY = self.h-y
        
        return true
    end
    
    if GUI.Element.mousepressed(self, x, y, button) then
        return true
    end
    
    if self.closeable and self:closeCollision(x, y) then
        self.closing = true
        
        return true
        
    elseif self.draggable and self:titleBarCollision(x, y) then
        self.dragging = true
        self.dragX = x
        self.dragY = y
        
        return true
    
    elseif self.scrollable[1] and self:scrollXCollision(x, y) then
        self.scrollingX = true
        self.scrollingXdragX = x-self:getScrollBarX()
        
        return true
        
    elseif self:collision(x, y) then
        return true
    end
end

function Box:mousereleased(x, y, button)
    GUI.Element.mousereleased(self, x, y, button)
    
    self.dragging = false
    self.resizing = false
    self.scrollingX = false
    
    if self.closing then
        if self:closeCollision(x, y) then
            self.parent:removeChild(self)
        else
            self.closing = false
        end
    end 
end

return Box
