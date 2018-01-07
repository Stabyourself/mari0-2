Checkbox = class("GUI.Checkbox", GUI.Element)

Checkbox.checkBoxPadding = 2

function Checkbox:initialize(x, y, s, func)
    self.s = s
    local w, h = 8, 8
    
    if self.s then
        w = w + #self.s*8 + Checkbox.checkBoxPadding
    end
    
    GUI.Element.initialize(self, x, y, w, h)
    
    if self.s then
        self:addChild(GUI.Text:new(self.s, 8+self.checkBoxPadding, 0))
    end
    
    self.func = func --boogie nights
    
    self.pressing = false
    self.value = false
end

function Checkbox:getCollision(x, y)
    return x >= 0 and x < self.w and y >= 0 and y < self.h
end 

function Checkbox:draw(level)
    GUI.Element.translate(self)
    
    love.graphics.setColor(1, 1, 1)
    
    local img = self.gui.img.checkbox
    
    if self.pressing then
        img = self.gui.img.checkboxActive
    elseif self:getCollision(self.mouse.x, self.mouse.y) then
        img = self.gui.img.checkboxHover
    end
    
    if self.value then
        img = img.on
    else
        img = img.off
    end
    
    love.graphics.draw(img, -2, -2)
    
    GUI.Element.draw(self, level)
    
    GUI.Element.unTranslate(self)
end

function Checkbox:mousepressed(x, y, Checkbox)
    if self:getCollision(x, y) then
        self.pressing = true
        
        return true
    end
end

function Checkbox:mousereleased(x, y, Checkbox)
    if self.pressing and self:getCollision(x, y) then
        self.value = not self.value
        
        if self.func then
            self.func(self)
        end
    end
    
    self.pressing = false
end

return Checkbox
