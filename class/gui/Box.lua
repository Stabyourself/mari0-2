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

    self.sizeMin = {12, 12}
    self.backgroundColor = {0, 0, 0, 0}
    
    self.children = {}
end

function Box:update(dt)
    if self.draggable then
        self.posMin[2] = 10
    end

    GUI.Element.update(self, dt)
end

function Box:draw(level)
    GUI.Element.translate(self)
    
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", 0, 0, self.w, self.h)
    
    love.graphics.setColor(255, 255, 255)
    
    -- Border
    local img = self.gui.img.box
    if self.draggable then
        img = self.gui.img.boxTitled
    end
    
    love.graphics.draw(img, boxQuad[1], -16, -16)
    love.graphics.draw(img, boxQuad[2], 0, -16, 0, self.w, 1)
    love.graphics.draw(img, boxQuad[3], self.w, -16)
    love.graphics.draw(img, boxQuad[4], -16, 0, 0, 1, self.h)
    
    love.graphics.draw(img, boxQuad[6], self.w, 0, 0, 1, self.h)
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
    
    GUI.Element.draw(self, level)
    
    GUI.Element.unStencil(self, level)
    
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
        self.dragPos = {x, y}
        
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
