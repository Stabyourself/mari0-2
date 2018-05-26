local Gui3 = ...
Gui3.Rectangle = class("Gui3.Rectangle", Gui3.Element)

Gui3.Rectangle.scale = 3

function Gui3.Rectangle:initialize(x, y, w, h)
    self.w = w
    self.h = h

    self.color = {255, 255, 255}

    Gui3.Element.initialize(self, x, y, self.w, self.h)
end

function Gui3.Rectangle:draw(level)
    Gui3.Element.translate(self)
    
    Gui3.Element.draw(self, level)

    love.graphics.scale(self.scale)
    love.graphics.rectangle("line", 0.5, 0.5, self.w, self.h)
    love.graphics.scale(1/self.scale)

    Gui3.Element.unTranslate(self)
end

return Gui3.Rectangle
