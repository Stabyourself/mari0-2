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

function Button:initialize(x, y, s, func)
    self.s = s
    local w, h
    
    if self.s then
        w = #self.s*8+2
        h = 10
    else
        w = 8
        h = 8
    end
    
    GUI.Element.initialize(self, x, y, w, h)
    
    self.func = func --boogie nights
end

function Button:getCollision(x, y)
    return x >= -2 and x < self.w+2 and y >= -2 and y < self.h+2
end 

function Button:draw(level)
    GUI.Element.translate(self)
    
    love.graphics.setColor(255, 255, 255)
    
    local img = self.gui.img.button
    
    if self:getCollision(self:getMouse()) then
        img = self.gui.img.buttonHover
    end
    
    love.graphics.draw(img, buttonQuad[1], -8, -8)
    love.graphics.draw(img, buttonQuad[2], 0, -8, 0, self.w, 1)
    love.graphics.draw(img, buttonQuad[3], self.w, -8)
    love.graphics.draw(img, buttonQuad[4], -8, 0, 0, 1, self.h)
    love.graphics.draw(img, buttonQuad[5], 0, 0, 0, self.w, self.h)
    love.graphics.draw(img, buttonQuad[6], self.w, 0, 0, 1, self.h)
    love.graphics.draw(img, buttonQuad[7], -8, self.h)
    love.graphics.draw(img, buttonQuad[8], 0, self.h, 0, self.w, 1)
    love.graphics.draw(img, buttonQuad[9], self.w, self.h)
    
    GUI.Element.stencil(self, level)
    
    GUI.Element.draw(self, level)
    
    if self.s then
        marioPrint(self.s, 1, 1)
    end
    
    GUI.Element.unStencil(self, level)
    GUI.Element.unTranslate(self)
end

function Button:mousepressed(x, y, button)
    if self:getCollision(x, y) then
        self.func()
    end
end

return Button
