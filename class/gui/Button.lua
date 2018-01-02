Button = class("GUI.Button")

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
    self.x = x
    self.y = y
    self.s = s
    
    if self.s then
        self.w = #self.s*8+2
        self.h = 10
    else
        self.w = 8
        self.h = 8
    end
    
    self.func = func --boogie nights
end

function Button:getCollision(x, y)
    return x >= -2 and x < self.w+2 and y >= -2 and y < self.h+2
end 

function Button:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    
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
    love.graphics.draw(img, buttonQuad[6], self.w, y, 0, 1, self.h)
    love.graphics.draw(img, buttonQuad[7], -8, self.h)
    love.graphics.draw(img, buttonQuad[8], 0, self.h, 0, self.w, 1)
    love.graphics.draw(img, buttonQuad[9], self.w, self.h)
    
    if self.s then
        marioPrint(self.s, 1, 1)
    end
    
    love.graphics.pop()
end

function Button:getMouse()
    local x, y = self.parent:getMouse()
    
    return x-self.x, y-self.y
end

function Button:mousepressed(x, y, button)
    x, y = x-self.x, y-self.y
    
    if self:getCollision(x, y) then
        self.func()
    end
end

return Button
