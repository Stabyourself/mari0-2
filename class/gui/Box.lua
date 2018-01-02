local Box = class("GUI.Box", GUI.Canvas)

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
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    
    self.backgroundColor = {0, 0, 0, 0}
    
    self.children = {}
end

function Box:update(dt)
    GUI.Canvas.update(self, dt)
    
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
        
        if x+self.resizeX <= self.parent.w then
            self.w = x-self.x+self.resizeX
        end
        
        if y+self.resizeY <= self.parent.h then
            self.h = y-self.y+self.resizeY
        end
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
end

function Box:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", 0, 0, self.w, self.h)
    
    love.graphics.setColor(255, 255, 255)
    
    -- topleft
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
    
    
    for _, v in ipairs(self.children) do
        love.graphics.stencil(function()
            love.graphics.rectangle("fill", 0, 0, self.w, self.h)
        end)
        love.graphics.setStencilTest("greater", 0)
        
        v:draw()
        
        love.graphics.setStencilTest()
    end
    
    
    if self.title then
        love.graphics.stencil(function()
            love.graphics.rectangle("fill", 0, -10, self.w, 10)
        end)
        love.graphics.setStencilTest("greater", 0)
        
        marioPrint(self.title, 0, -10)
        
        love.graphics.setStencilTest()
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
    
    if self.closeable then
        if self.closing then
            love.graphics.draw(self.gui.img.boxCloseActive, self.w-11, -13)
        elseif self:closeCollision(self:getMouse()) then
            love.graphics.draw(self.gui.img.boxCloseHover, self.w-11, -13)
        else
            love.graphics.draw(self.gui.img.boxClose, self.w-11, -13)
        end
    end
    
    love.graphics.pop()
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
    x, y = self:getMouse()
    
    if GUI.Canvas.mousepressed(self, x, y, button) then
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
        
    elseif self.resizeable and self:resizeCornerCollision(x, y) then
        self.resizing = true
        self.resizeX = self.w-x
        self.resizeY = self.h-y
        
        return true
        
    elseif self:collision(x, y) then
        return true
    end
end

function Box:mousereleased(x, y, button)
    x, y = self:getMouse()
    GUI.Canvas.mousereleased(self, x, y, button)
    
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

function Box:getMouse()
    local x, y = self.parent:getMouse()
    
    return x-self.x, y-self.y
end

return Box
