local Gui3 = ...
Gui3.Canvas = class("Gui3.Canvas", Gui3.Element)

Gui3.Canvas.movesToTheFront = true

function Gui3.Canvas:initialize(x, y, w, h)
    Gui3.Element.initialize(self, x, y, w, h)

    self.children = {}
    self.background = {0, 0, 0, 0}
end

function Gui3.Canvas:draw(level)
    Gui3.Element.translate(self)

    love.graphics.setColor(self.background)
    love.graphics.rectangle("fill", 0, 0, self.w, self.h)

    Gui3.Element.draw(self, level)

    Gui3.Element.unTranslate(self)
end

function Gui3.Canvas:update(dt, x, y, mouseBlocked, absX, absY)
    Gui3.Element.update(self, dt, x, y, mouseBlocked, absX, absY)
end

function Gui3.Canvas:debugDraw()
    local regions = {}

    self:getMouseZone(regions, 0, 0, 0, 0, self.w, self.h)

    for i = 2, #regions do
        local region = regions[i]
        local r, g, b = region.element.debugColor:rgb()
        love.graphics.setColor(r, g, b, 0.9)
        love.graphics.rectangle("fill", region.x, region.y, region.w, region.h)
    end
    love.graphics.setColor(1, 1, 1, 1)
end