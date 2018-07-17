local Gui3 = ...
Gui3.Slider = class("Gui3.Slider", Gui3.Element)

local sliderQuad = {
    love.graphics.newQuad(0, 0, 8, 8, 17, 8),
    love.graphics.newQuad(8, 0, 1, 8, 17, 8),
    love.graphics.newQuad(9, 0, 8, 8, 17, 8),
}

Gui3.Slider.barOffset = 2
Gui3.Slider.textWidth = 25

function Gui3.Slider:initialize(min, max, x, y, w, showValue, func)
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

function Gui3.Slider:mousemoved(x, y)
    local ret = Gui3.Element.mousemoved(self, x, y)

    if self.dragging then
        local prevVal = self.val
        local newVal = (x-self.dragX-self.barOffset)/(self.barWidth)

        newVal = math.clamp(newVal, 0, 1)

        if newVal ~= prevVal then
            self:setValue(newVal*(self.max-self.min)+self.min)
        end
    end

    return ret
end

function Gui3.Slider:getValue()
    return self.min + (self.max-self.min)*self.val
end

function Gui3.Slider:setValue(newVal)
    if newVal ~= self.val then
        self.val = (newVal-self.min)/(self.max-self.min)

        if self.showValue then
            self.text:setString(tostring(math.round(self:getValue())))
        end

        if self.func then
            self.func(self:getValue())
        end

        self:updateRender()
    end
end

function Gui3.Slider:getCollision(x, y)
    local sliderX = self:getPosX()

    return x >= sliderX-2 and x < sliderX+2 and y >= 0 and y < 8
end

function Gui3.Slider:getPosX()
    return self.val*(self.barWidth)+self.barOffset
end

function Gui3.Slider:draw()
    love.graphics.setColor(self.color.bar)

    love.graphics.draw(self.gui.img.sliderBar, sliderQuad[1], 0, 0)
    love.graphics.draw(self.gui.img.sliderBar, sliderQuad[2], 8, 0, 0, self.barWidth+self.barOffset*2-16, 1)
    love.graphics.draw(self.gui.img.sliderBar, sliderQuad[3], self.barWidth+self.barOffset*2-8, 0)

    local img = self.gui.img.slider

    if self.dragging then
        img = self.gui.img.sliderActive
    elseif self.mouse[1] and self:getCollision(self.mouse[1], self.mouse[2]) then
        img = self.gui.img.sliderHover
    end

    love.graphics.setColor(self.color.slider)

    love.graphics.draw(img, self:getPosX(), 0, 0, 1, 1, 4)

    love.graphics.setColor(1, 1, 1)

    Gui3.Element.draw(self)
end

function Gui3.Slider:mousepressed(x, y, button)
    if self:getCollision(x, y) then
        self.dragging = true
        self.dragX = x-self:getPosX()

        self.exclusiveMouse = true
        self:updateRender()
    end

    Gui3.Element.mousepressed(self, x, y, button)
end

function Gui3.Slider:mousereleased(x, y, button)
    self.dragging = false
    self:updateRender()

    Gui3.Element.mousereleased(self, x, y, button)
end
