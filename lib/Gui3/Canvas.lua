local Canvas = class("Gui3.Canvas", Gui3.Element)

Canvas.movesToTheFront = true

function Canvas:initialize(x, y, w, h)
    Gui3.Element.initialize(self, x, y, w, h)

    self.children = {}
    self.background = {0, 0, 0, 0}
end

function Canvas:draw(level)
    Gui3.Element.translate(self)

    love.graphics.setColor(self.background)
    love.graphics.rectangle("fill", 0, 0, self.w, self.h)

    Gui3.Element.draw(self, level)

    Gui3.Element.unTranslate(self)
end

return Canvas
