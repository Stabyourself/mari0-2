local Slider = class("GUI.Slider", GUI.Element)

local sliderQuad = {
    love.graphics.newQuad(0, 0, 8, 8, 17, 8),
    love.graphics.newQuad(8, 0, 1, 8, 17, 8),
    love.graphics.newQuad(9, 0, 8, 8, 17, 8),
}

Slider.barOffset = 2
Slider.textWidth = 25

function Slider:initialize(min, max, x, y, w, showValue)
    self.min = min
    self.max = max
    self.showValue = showValue
    
    self.val = 0
    
    self.barWidth = w-self.barOffset*2
    
    if showValue then
        self.barWidth = self.barWidth - self.textWidth
    end
    
    self.text = GUI.Text:new(tostring(self:getValue()), w-self.textWidth+1, 0)
    
    GUI.Element.initialize(self, x, y, w, 8)
    
    self:addChild(self.text)
end

function Slider:update(dt, x, y, mouseBlocked)
    GUI.Element.update(self, dt, x, y, mouseBlocked)
    
    if self.dragging then
        local pos = (self.mouse[1]-self.dragX-self.barOffset)/(self.barWidth)
        
        pos = math.clamp(pos, 0, 1)
        
        self.val = pos
        
        if self.showValue then
            self.text:setString(tostring(math.round(self:getValue())))
        end
    end
end

function Slider:getValue()
    return self.min + (self.max-self.min)*self.val
end

function Slider:getCollision(x, y)
    local sliderX = self:getPosX()
    
    return not self.mouseBlocked and x >= sliderX-2 and x < sliderX+2 and y >= 0 and y < 8
end

function Slider:getPosX()
    return self.val*(self.barWidth)+self.barOffset
end

function Slider:draw(level)
    GUI.Element.translate(self)
    
    GUI.Element.draw(self, level)
    
    love.graphics.draw(self.gui.img.sliderBar, sliderQuad[1], 0, 0)
    love.graphics.draw(self.gui.img.sliderBar, sliderQuad[2], 8, 0, 0, self.barWidth+self.barOffset*2-16, 1)
    love.graphics.draw(self.gui.img.sliderBar, sliderQuad[3], self.barWidth+self.barOffset*2-8, 0)
    
    local img = self.gui.img.slider

    if self.dragging then
        img = self.gui.img.sliderActive
    elseif self:getCollision(self.mouse[1], self.mouse[2]) then
        img = self.gui.img.sliderHover
    end
    
    love.graphics.draw(img, self:getPosX(), 0, 0, 1, 1, 4)

    GUI.Element.unTranslate(self)
end

function Slider:mousepressed(x, y, button)
    if self:getCollision(x, y) then
        self.dragging = true
        self.dragX = x-self:getPosX()
    end
    
    GUI.Element.mousepressed(self, x, y, button)
end
function Slider:mousereleased(x, y, button)
    self.dragging = false

    GUI.Element.mousereleased(self, x, y, button)
end

return Slider
