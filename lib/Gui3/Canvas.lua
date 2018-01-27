local Canvas = class("Gui3.Canvas", Gui3.Element)

Canvas.movesToTheFront = true

function Canvas:initialize(x, y, w, h)
    Gui3.Element.initialize(self, x, y, w, h)

    self.children = {}
    self.background = {0, 0, 0, 0}
end

function Canvas:render(level)
    love.graphics.setColor(self.background)
    love.graphics.rectangle("fill", 0, 0, self.w, self.h)

    Gui3.Element.render(self, level)
end

return Canvas
