Button = class("GUI.Button", GUI.Element)

local buttonQuad = {
    love.graphics.newQuad(0, 0, 8, 8, 17, 17),
    love.graphics.newQuad(8, 0, 1, 8, 17, 17),
    love.graphics.newQuad(9, 0, 8, 8, 17, 17),
    love.graphics.newQuad(0, 8, 8, 1, 17, 17),
    love.graphics.newQuad(8, 8, 1, 1, 17, 17),
    love.graphics.newQuad(9, 8, 8, 1, 17, 17),
    love.graphics.newQuad(0, 9, 8, 8, 17, 17),
    love.graphics.newQuad(8, 9, 1, 8, 17, 17),
    love.graphics.newQuad(9, 9, 8, 8, 17, 17),
}

Button.padding = 1

function Button:initialize(x, y, s, func)
    self.s = s
    local w = self.padding*2+4
    local h = self.padding*2+4
    
    if self.s then
        w = w+#self.s*8
        h = h + 8
    end
    
    GUI.Element.initialize(self, x, y, w, h)
    
    if self.s then
        self:addChild(GUI.Text:new(self.s, 2+self.padding, 2+self.padding))
    end
    
    self.func = func
    
    self.pressing = false
end

function Button:getCollision(x, y)
    return not self.mouseBlocked and  x >= 0 and x < self.w and y >= 0 and y < self.h
end 

function Button:draw(level)
    GUI.Element.translate(self)
    
    love.graphics.setColor(1, 1, 1)
    
    local img = self.gui.img.button
    
    if self.pressing then
        img = self.gui.img.buttonActive
    elseif self:getCollision(self.mouse.x, self.mouse.y) then
        img = self.gui.img.buttonHover
    end
    
    love.graphics.draw(img, buttonQuad[1], -6, -6)
    love.graphics.draw(img, buttonQuad[2], 2, -6, 0, self.w-4, 1)
    love.graphics.draw(img, buttonQuad[3], self.w-2, -6)
    love.graphics.draw(img, buttonQuad[4], -6, 2, 0, 1, self.h-4)
    love.graphics.draw(img, buttonQuad[5], 2, 2, 0, self.w-4, self.h-4)
    love.graphics.draw(img, buttonQuad[6], self.w-2, 2, 0, 1, self.h-4)
    love.graphics.draw(img, buttonQuad[7], -6, self.h-2)
    love.graphics.draw(img, buttonQuad[8], 2, self.h-2, 0, self.w-4, 1)
    love.graphics.draw(img, buttonQuad[9], self.w-2, self.h-2)
    
    GUI.Element.draw(self, level)
    
    GUI.Element.unTranslate(self)
end

function Button:mousepressed(x, y, button)
    if self:getCollision(x, y) then
        self.pressing = true
    end
    
    GUI.Element.mousepressed(self, x, y, button)
end

function Button:mousereleased(x, y, button)
    if self.pressing and self:getCollision(x, y) then
        if self.func then
            self.func(self)
        end
    end
    
    self.pressing = false

    GUI.Element.mousereleased(self, x, y, button)
end

return Button
