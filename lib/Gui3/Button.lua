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

function Gui3.Button:addSubDraw(func, y)
    self:addChild(Gui3.SubDraw:new(func, 0, y))
end

function Gui3.Button:initialize(x, y, content, border, padding, func, sizeX, sizeY)
    self.padding = padding or 1
    
    self.border = border

    if self.border then 
        self.padding = self.padding + 3 
    end

    Gui3.Element.initialize(self, x, y, 0, 0)

    local y = 0
    local maxW = 0

    if type(content) ~= "table" then
        content = {content}
    end

    for _, el in ipairs(content) do
        if type(el) == "string" then
            self:addText(el, y)

            y = y + 9
            maxW = math.max(maxW, #el*8)

        elseif type(el) == "userdata" then -- simple image
            self:addImage(el, y)

            y = y + el:getHeight()+1
            maxW = math.max(maxW, el:getWidth())

        elseif type(el) == "table" then -- advanced image
            self:addImage(el.img, y)

            y = y + ((el.h + 1) or (el.img:getHeight())+1)
            maxW = math.max(maxW, (el.clipX or el.img:getWidth()))
        elseif type(el) == "function" then -- subdraw
            self:addSubDraw(el, y)
        end
    end
    
    local w = maxW
    local h = y-1

    if sizeX then
        w = sizeX
    end

    if sizeY then
        h = sizeY
    end
    
    self.childBox = {self.padding, self.padding, w, h}

    w = w + self.padding*2
    h = h + self.padding*2

    self.w = w
    self.h = h

    self.func = func

    self.clip = true
    self.pressing = false
    self.color = {
        background = {1, 1, 1},
        normal = {0, 0, 0, 0},
        hover = {0, 0, 0, 0.25},
        active = {0, 0, 0, 0.375},
        img = {1, 1, 1, 1},
    }
end

function Gui3.Button:getCollision(x, y)
    return not self.mouseBlocked and x >= 0 and x < self.w and y >= 0 and y < self.h
end 

function Gui3.Button:draw(level)
    Gui3.Element.translate(self)
    
    love.graphics.setColor(1, 1, 1)
    
    if self.border then
        local img = self.gui.img.button
        
        if self.pressing then
            img = self.gui.img.buttonActive
        elseif self:getCollision(self.mouse[1], self.mouse[2]) then
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
        elseif self:getCollision(self.mouse[1], self.mouse[2]) then
            love.graphics.setColor(self.color.hover)
        end
        
        love.graphics.rectangle("fill", 0, 0, self.w, self.h)
    end
    
    love.graphics.setColor(1, 1, 1)
    
    Gui3.Element.draw(self, level)
    
    Gui3.Element.unTranslate(self)
end

function Gui3.Button:mousepressed(x, y, button)
    if self:getCollision(x, y) then
        self.pressing = true
    end
    
    return Gui3.Element.mousepressed(self, x, y, button)
end

function Gui3.Button:mousereleased(x, y, button)
    if self.pressing and self:getCollision(x, y) then
        if self.func then
            self.func(self)
        end
    end
    
    self.pressing = false

    Gui3.Element.mousereleased(self, x, y, button)
end
