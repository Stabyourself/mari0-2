local Slider = class("Gui3.Slider", Gui3.Element)

local sliderQuad = {
    love.graphics.newQuad(0, 0, 8, 8, 17, 8),
    love.graphics.newQuad(8, 0, 1, 8, 17, 8),
    love.graphics.newQuad(9, 0, 8, 8, 17, 8),
}

Slider.barOffset = 2
Slider.textWidth = 25

function Slider:initialize(min, max, x, y, w, showValue, func)
    self.min = min
    self.max = max
    self.showValue = showValue
    
    self.val = 0
    self.func = func
    
    self.barWidth = w-self.barOffset*2
    
    if showValue then
        self.barWidth = self.barWidth - self.textWidth
        self.text = Gui3.Text:new(tostring(self:getValue()), w-self.textWidth+1, 0)
    end
    
    Gui3.Element.initialize(self, x, y, w, 8)
    
    if showValue then
        self:addChild(self.text)
    end
    
    self.color = {
        bar = {1, 1, 1},
        slider = {1, 1, 1},
    }
end

function Slider:update(dt, x, y, mouseBlocked, absX, absY)
    local ret = Gui3.Element.update(self, dt, x, y, mouseBlocked, absX, absY)
    
    if self.dragging then
        local pos = (self.mouse[1]-self.dragX-self.barOffset)/(self.barWidth)
        
        pos = math.clamp(pos, 0, 1)
        
        self.val = pos
        
        if self.showValue then
            self.text:setString(tostring(math.round(self:getValue())))
        end
        
        if self.func then
            self.func(self:getValue())
        end
    end

    return ret
end

function Slider:getValue()
    return self.min + (self.max-self.min)*self.val
end

function Slider:setValue(val)
    self.val = (val-self.min)/(self.max-self.min)
end

function Slider:getCollision(x, y)
    local sliderX = self:getPosX()
    
    return not self.mouseBlocked and x >= sliderX-2 and x < sliderX+2 and y >= 0 and y < 8
end

function Slider:getPosX()
    return self.val*(self.barWidth)+self.barOffset
end

function Slider:render(level)
    Gui3.Element.render(self, level)
    
    love.graphics.setColor(self.color.bar)
    
    love.graphics.draw(self.gui.img.sliderBar, sliderQuad[1], 0, 0)
    love.graphics.draw(self.gui.img.sliderBar, sliderQuad[2], 8, 0, 0, self.barWidth+self.barOffset*2-16, 1)
    love.graphics.draw(self.gui.img.sliderBar, sliderQuad[3], self.barWidth+self.barOffset*2-8, 0)
    
    local img = self.gui.img.slider

    if self.dragging then
        img = self.gui.img.sliderActive
    elseif self:getCollision(self.mouse[1], self.mouse[2]) then
        img = self.gui.img.sliderHover
    end
    
    love.graphics.setColor(self.color.slider)
    
    love.graphics.draw(img, self:getPosX(), 0, 0, 1, 1, 4)
    
    love.graphics.setColor(1, 1, 1)
end

function Slider:mousepressed(x, y, button)
    if self:getCollision(x, y) then
        self.dragging = true
        self.dragX = x-self:getPosX()
    end
    
    return Gui3.Element.mousepressed(self, x, y, button)
end
function Slider:mousereleased(x, y, button)
    self.dragging = false

    Gui3.Element.mousereleased(self, x, y, button)
end

return Slider
