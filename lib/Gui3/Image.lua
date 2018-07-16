local Gui3 = ...
Gui3.Image = class("Gui3.Image", Gui3.Element)

Gui3.Image.noMouseEvents = true

function Gui3.Image:initialize(img, x, y, quad, scale)
    if type(img) == "string" then
        self.img = love.graphics.newImage(img)
    else
        self.img = img
    end

    self.quad = quad
    self.scale = scale or 1

    self.color = {1, 1, 1, 1}

    Gui3.Element.initialize(self, x, y, self.img:getWidth()*self.scale, self.img:getHeight()*self.scale)
end

function Gui3.Image:draw(level)
    Gui3.Element.draw(self, level)

    love.graphics.setColor(self.color)

    if self.quad then
        love.graphics.draw(self.img, self.quad, 0, 0, 0, self.scale, self.scale)
    else
        love.graphics.draw(self.img, 0, 0, 0, self.scale, self.scale)
    end

    love.graphics.setColor(1, 1, 1)
end

function Gui3.Image:setQuad(quad)
    if self.quad ~= quad then
        self.quad = quad
        self:updateRender()
    end
end