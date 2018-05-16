local Image = class("Gui3.Image", Gui3.Element)

function Image:initialize(img, x, y, quad)
    if type(img) == "string" then
        self.img = love.graphics.newImage(img)
    else
        self.img = love.graphics.newImage(img)
    end

    if quad then
        self.quad = quad
    end
    
    Gui3.Element.initialize(self, x, y, self.img:getWidth(), self.img:getHeight())
end

function Image:draw(level)
    Gui3.Element.translate(self)
    
    Gui3.Element.draw(self, level)
    
    if self.quad then
        love.graphics.draw(self.img, self.quad, 0, 0)
    else
        love.graphics.draw(self.img, 0, 0)
    end

    Gui3.Element.unTranslate(self)
end

return Image
