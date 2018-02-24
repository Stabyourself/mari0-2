Checkbox = class("Gui3.Checkbox", Gui3.Element)

Checkbox.checkBoxPadding = 2

function Checkbox:initialize(x, y, s, padding, func, val)
    self.s = s
    self.padding = padding or 0
    
    local w, h = 10+self.padding*2, 10+self.padding*2
    
    if self.s then
        w = w + #self.s*8 + Checkbox.checkBoxPadding
    end
    
    Gui3.Element.initialize(self, x, y, w, h)
    
    if self.s then
        self:addChild(Gui3.Text:new(self.s, 10+self.checkBoxPadding+self.padding, self.padding+1))
    end
    
    self.func = func --boogie nights
    
    self.pressing = false
    self.value = val == nil and false or val
end

function Checkbox:getCollision(x, y)
    return not self.mouseBlocked and x >= 0 and x < self.w and y >= 0 and y < self.h
end 

function Checkbox:draw(level)
    Gui3.Element.translate(self)
    
    love.graphics.setColor(1, 1, 1)
    
    local img = self.gui.img.checkbox
    
    if self.pressing then
        img = self.gui.img.checkboxActive
    elseif self:getCollision(self.mouse[1], self.mouse[2]) then
        img = self.gui.img.checkboxHover
    end
    
    if self.value then
        img = img.on
    else
        img = img.off
    end
    
    love.graphics.draw(img, self.padding, self.padding)
    
    Gui3.Element.draw(self, level)
    
    Gui3.Element.unTranslate(self)
end

function Checkbox:mousepressed(x, y, Checkbox)
    if self:getCollision(x, y) then
        self.pressing = true
    end

    return Gui3.Element.mousepressed(self, x, y, button)
end

function Checkbox:mousereleased(x, y, Checkbox)
    if self.pressing and self:getCollision(x, y) then
        self.value = not self.value
        
        if self.func then
            self.func(self)
        end
    end
    
    self.pressing = false

    return Gui3.Element.mousereleased(self, x, y, button)
end

return Checkbox
