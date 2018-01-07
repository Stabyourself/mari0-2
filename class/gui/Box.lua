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

function Box:initialize(x, y, w, h)
    GUI.Element.initialize(self, x, y, w, h)

    self.sizeMin.x = 33
    self.sizeMin.y = 33
    
    self.background = {0, 0, 0, 0}
    self.backgroundQuad = love.graphics.newQuad(0, 0, 4, 4, 4, 4)
    
    self.children = {}
    
    self.posMin.x = -3
    self.posMin.y = -2
    
    self.posMax.x = -3
    self.posMax.y = -4
end

function Box:update(dt, x, y)
    if self.draggable then
        self.childBox = {3, 12, self.w-6, self.h-16}
    else
        self.childBox = {2, 3, self.w-4, self.h-6}
    end
    
    GUI.Element.update(self, dt, x, y)
end

function Box:draw(level)
    GUI.Element.translate(self)
    
    if type(self.background) == "table" then
        love.graphics.setColor(self.background)
        love.graphics.rectangle("fill", self.childBox[1], self.childBox[2], self.childBox[3], self.childBox[4])
    elseif type(self.background) == "userdata" then
        self.backgroundQuad:setViewport(0, 0, self.childBox[3], self.childBox[4])
        self.background:setWrap("repeat", "repeat")
            
        love.graphics.draw(self.background, self.backgroundQuad, self.childBox[1], self.childBox[2])
    end
    
    
    love.graphics.setColor(1, 1, 1)
    
    -- Border
    local img = self.gui.img.box
    if self.draggable then
        img = self.gui.img.boxTitled
    end
    
    love.graphics.draw(img, boxQuad[1], 0, 0)
    love.graphics.draw(img, boxQuad[2], 16, 0, 0, self.w-32, 1)
    love.graphics.draw(img, boxQuad[3], self.w-16, 0)
    love.graphics.draw(img, boxQuad[4], 0, 16, 0, 1, self.h-32)
    
    love.graphics.draw(img, boxQuad[6], self.w-16, 16, 0, 1, self.h-32)
    love.graphics.draw(img, boxQuad[7], 0, self.h-16)
    love.graphics.draw(img, boxQuad[8], 16, self.h-16, 0, self.w-32, 1)
    love.graphics.draw(img, boxQuad[9], self.w-16, self.h-16)
    
    if self.title then
        love.graphics.stencil(function()
            love.graphics.rectangle("fill", 3, 2, self.w-16, 8)
        end, "increment", 1, true)
        love.graphics.setStencilTest("equal", level)
        
        marioPrint(self.title, 3, 2)
        
        love.graphics.stencil(function()
            love.graphics.rectangle("fill", 3, 2, self.w-16, 8)
        end, "decrement", 1, true)
        love.graphics.setStencilTest("equal", level-1)
    end
    
    if self.closeable then
        local img = self.gui.img.boxClose
        if self.closing then
            img = self.gui.img.boxCloseActive
        elseif self:closeCollision(self.mouse.x, self.mouse.y) then
            img = self.gui.img.boxCloseHover
        end
        
        love.graphics.draw(img, self.w-12, 2)
    end
    
    GUI.Element.draw(self, level)
    
    if self.resizeable then
        local img = self.gui.img.boxResize
        if self.resizing then
            img = self.gui.img.boxResizeActive
        elseif self:resizeCornerCollision(self.mouse.x, self.mouse.y) then
            img = self.gui.img.boxResizeHover
        end
        
        love.graphics.draw(img, self.w-12, self.h-13)
    end
    
    GUI.Element.unTranslate(self)
end

function Box:titleBarCollision(x, y)
    return x >= 0 and x < self.w and y >= 0 and y < 12
end

function Box:resizeCornerCollision(x, y)
    return x >= self.w-12 and x < self.w-3 and y >= self.h-13 and y < self.h-4
end

function Box:closeCollision(x, y)
    return x >= self.w-12 and x < self.w-3 and y >= 2 and y < 11
end

function Box:collision(x, y)
    return x >= -2 and x < self.w+2 and y >= -2 and y < self.h+3
end

function Box:mousepressed(x, y, button)
    -- Check resize before the rest because reasons
    if self.resizeable and self:resizeCornerCollision(x, y) then
        self.resizing = true
        self.resizePos.x = self.w-x
        self.resizePos.y = self.h-y
        
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
        self.dragPos.x = x
        self.dragPos.y = y
        
        return true
        
    elseif self:collision(x, y) then
        return true
    end
end

function Box:mousereleased(x, y, button)
    GUI.Element.mousereleased(self, x, y, button)
    
    self.dragging = false
    self.resizing = false
    
    if self.closing then
        if self:closeCollision(x, y) then
            self.parent:removeChild(self)
        else
            self.closing = false
        end
    end 
end

return Box
