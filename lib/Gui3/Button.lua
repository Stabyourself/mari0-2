local Gui3 = ...
Gui3.Button = class("Gui3.Button", Gui3.Element)

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

function Gui3.Button:addText(text, y)
    self:addChild(Gui3.Text:new(text, 0, y))
end

function Gui3.Button:addImage(img, y)
    self:addChild(Gui3.Image:new(img, 0, y))
end

function Gui3.Button:addSubDraw(func, y, w, h)
    local subDraw = Gui3.SubDraw:new(func, 0, y, w, h)
    subDraw.noMouseEvents = true
    self:addChild(subDraw)
end

function Gui3.Button:draw()
    love.graphics.setColor(1, 1, 1)

    if self.border then
        local img = self.gui.img.button

        if self.pressing then
            img = self.gui.img.buttonActive
        elseif self.mouse[1] then
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
    else
        love.graphics.setColor(self.color.background)
        love.graphics.rectangle("fill", 0, 0, self.w, self.h)

        love.graphics.setColor(self.color.normal)

        if self.pressing then
            love.graphics.setColor(self.color.active)
        elseif self.mouse[1] then
            love.graphics.setColor(self.color.hover)
        end

        love.graphics.rectangle("fill", 0, 0, self.w, self.h)
    end

    love.graphics.setColor(1, 1, 1)

    Gui3.Element.draw(self)
end

function Gui3.Button:mousepressed(x, y, button)
    self.pressing = true
    self.exclusiveMouse = true
    self:updateRender()

    return Gui3.Element.mousepressed(self, x, y, button)
end

function Gui3.Button:getCollision(x, y)
    return x >= 0 and x < self.w and y >= 0 and y < self.h
end

function Gui3.Button:mousereleased(x, y, button)
    if self.pressing and self:getCollision(self.mouse[1], self.mouse[2]) then
        if self.func then
            self.func(self)
        end

        self:updateRender()
    end

    self.pressing = false

    Gui3.Element.mousereleased(self, x, y, button)
end

function Gui3.Button:mouseentered(x, y)
    Gui3.Element.mouseentered(self, x, y)

    self:updateRender()
end

function Gui3.Button:mouseleft(x, y)
    Gui3.Element.mouseleft(self, x, y)

    self:updateRender()
end


Gui3.TextButton = class("Gui3.TextButton", Gui3.Button)

function Gui3.TextButton:initialize(x, y, s, border, padding, func)
    self.border = border
    self.padding = padding or 1
    self.func = func

    if self.border then
        self.padding = self.padding + 3
    end

    self.childPadding = {self.padding, self.padding, self.padding, self.padding}

    local text = Gui3.Text:new(s, 0, 0)

    local w = text.w+self.padding*2
    local h = text.h+self.padding*2

    Gui3.Element.initialize(self, x, y, w, h)

    self:addChild(text)

    self.pressing = false
    self.color = {
        background = {1, 1, 1},
        normal = {0, 0, 0, 0},
        hover = {0, 0, 0, 0.5},
        active = {0, 0, 0, 0.6},
    }
end


Gui3.ImageButton = class("Gui3.ImageButton", Gui3.Button)

function Gui3.ImageButton:initialize(x, y, img, border, padding, func)
    self.border = border
    self.padding = padding or 1
    self.func = func

    if self.border then
        self.padding = self.padding + 3
    end

    self.childPadding = {self.padding, self.padding, self.padding, self.padding}

    local image = Gui3.Image:new(img, 0, 0)

    local w = image.w+self.padding*2
    local h = image.h+self.padding*2

    Gui3.Element.initialize(self, x, y, w, h)

    self:addChild(image)

    self.pressing = false
    self.color = {
        background = {1, 1, 1},
        normal = {0, 0, 0, 0},
        hover = {0, 0, 0, 0.5},
        active = {0, 0, 0, 0.6},
    }
end


Gui3.ComponentButton = class("Gui3.ComponentButton", Gui3.Button)

function Gui3.ComponentButton:initialize(x, y, elements, border, padding, func)
    self.padding = padding or 1

    self.border = border

    if self.border then
        self.padding = self.padding + 3
    end

    local elY = 0
    local maxW = 0

    for _, element in ipairs(elements) do
        element.y = elY

        elY = elY + element.h + 1

        if element.w > maxW then
            maxW = element.w
        end
    end

    local w = maxW+self.padding*2
    local h = elY-1+self.padding*2

    print(w, h)

    self.childPadding = {self.padding, self.padding, self.padding, self.padding}

    Gui3.Element.initialize(self, x, y, w, h)


    for _, element in ipairs(elements) do
        self:addChild(element)
    end

    self.func = func

    self.pressing = false
    self.color = {
        background = {1, 1, 1},
        normal = {0, 0, 0, 0},
        hover = {0, 0, 0, 0.5},
        active = {0, 0, 0, 0.6},
    }
end