local Gui3 = ...
Gui3.Image = class("Gui3.Image", Gui3.Element)

function Gui3.Image:initialize(img, x, y, quad)
    if type(img) == "string" then
        self.img = love.graphics.newImage(img)
    else
        self.img = img
    end

    if quad then
        self.quad = quad
    end

    self.color = {1, 1, 1, 1}
    
    Gui3.Element.initialize(self, x, y, self.img:getWidth(), self.img:getHeight())
end

function Gui3.Image:draw(level)
    Gui3.Element.translate(self)
    
    Gui3.Element.draw(self, level)

    love.graphics.setColor(self.color)
    
    if self.quad then
        love.graphics.draw(self.img, self.quad, 0, 0)
    else
        love.graphics.draw(self.img, 0, 0)
    end

    love.graphics.setColor(1, 1, 1)

    Gui3.Element.unTranslate(self)
end
