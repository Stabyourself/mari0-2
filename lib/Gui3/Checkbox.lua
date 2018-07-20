local Gui3 = ...
Gui3.Checkbox = class("Gui3.Checkbox", Gui3.Element)

Gui3.Checkbox.checkBoxPadding = 2

function Gui3.Checkbox:initialize(x, y, s, padding, func, val)
    self.s = s
    self.padding = padding or 0

    local w, h = 10+self.padding*2, 10+self.padding*2

    if self.s then
        w = w + #self.s*8 + self.checkBoxPadding
    end

    Gui3.Element.initialize(self, x, y, w, h)

    if self.s then
        self:addChild(Gui3.Text:new(self.s, 10+self.checkBoxPadding+self.padding, self.padding+1))
    end

    self.func = func --boogie nights

    self.pressing = false
    self.value = val == nil and false or val
end

function Gui3.Checkbox:draw()
    love.graphics.setColor(1, 1, 1)

    local img = self.gui.img.checkbox

    if self.pressing then
        img = self.gui.img.checkboxActive
    elseif self.mouse[1] then
        img = self.gui.img.checkboxHover
    end

    if self.value then
        img = img.on
    else
        img = img.off
    end

    love.graphics.draw(img, self.padding, self.padding)

    Gui3.Element.draw(self)
end

function Gui3.Checkbox:setValue(val)
    if val ~= self.value then
        self.value = val
        self:updateRender()
    end
end

function Gui3.Checkbox:mousepressed(x, y, checkbox)
    self.pressing = true
    self:updateRender()
    self.exclusiveMouse = true

    return true
end

function Gui3.Checkbox:getCollision(x, y)
    return x >= 0 and x < self.w and y >= 0 and y < self.h
end

function Gui3.Checkbox:mousereleased(x, y, checkbox)
    if self.pressing and self:getCollision(self.mouse[1], self.mouse[2]) then
        self:setValue(not self.value)

        if self.func then
            self.func(self)
        end
    end

    self.exclusiveMouse = false
    self.pressing = false

    return true
end

function Gui3.Checkbox:mouseentered(x, y)
    Gui3.Element.mouseentered(self, x, y)

    self:updateRender()
end

function Gui3.Checkbox:mouseleft(x, y)
    Gui3.Element.mouseleft(self, x, y)

    self:updateRender()
end
