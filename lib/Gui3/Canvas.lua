local Gui3 = ...
Gui3.Canvas = class("Gui3.Canvas", Gui3.Element)

Gui3.Canvas.movesToTheFront = true

function Gui3.Canvas:initialize(x, y, w, h)
    Gui3.Element.initialize(self, x, y, w, h)

    self.children = {}
    self.background = {0, 0, 0, 0}
    self.mouseRegions = {}
    self.lastMouseRegion = nil

    self.lastMouseX = 0
    self.lastMouseY = 0
end

function Gui3.Canvas:draw(level)
    Gui3.Element.translate(self)

    love.graphics.setColor(self.background)
    love.graphics.rectangle("fill", 0, 0, self.w, self.h)

    Gui3.Element.draw(self, level)

    Gui3.Element.unTranslate(self)
end

function Gui3.Canvas:updateMouseRegions()
    self.mouseRegions = {}

    self:getMouseZone(self.mouseRegions, 0, 0, 0, 0, self.w, self.h)
end

function Gui3.Canvas:rootmousemoved(x, y)
    local diffX = x-self.lastMouseX
    local diffY = y-self.lastMouseY

    self.lastMouseX = x
    self.lastMouseY = y

    if self.lastMouseRegion then
        self.lastMouseRegion.element:mousemoved(x-self.lastMouseRegion.offsetX, y-self.lastMouseRegion.offsetY, diffX, diffY)
    end

    if not self.lastMouseRegion or not self.lastMouseRegion.element.exclusiveMouse then
        for i = #self.mouseRegions, 2, -1 do -- 1 is this canvas, and mouse clicks should go through it
            local region = self.mouseRegions[i]

            if pointInRectangle(x, y, region.x, region.y, region.w, region.h) then
                if region ~= self.lastMouseRegion then
                    if self.lastMouseRegion then
                        self.lastMouseRegion.element:mouseleft(x-self.lastMouseRegion.offsetX, y-self.lastMouseRegion.offsetY)
                    end
                    region.element:mouseentered(x-region.offsetX, y-region.offsetY)

                    self.lastMouseRegion = region
                end

                return true
            end
        end
    end
end

function Gui3.Canvas:rootmousepressed(x, y, button)
    for i = #self.mouseRegions, 2, -1 do -- 1 is this canvas, and mouse clicks should go through it
        local region = self.mouseRegions[i]

        if pointInRectangle(x, y, region.x, region.y, region.w, region.h) then
            region.element:mousepressed(x-region.offsetX, y-region.offsetY, button)

            return true
        end
    end
end

function Gui3.Canvas:rootmousereleased(x, y, button)
    if self.lastMouseRegion.element.exclusiveMouse then
        self.lastMouseRegion.element:mousereleased(x-self.lastMouseRegion.offsetX, y-self.lastMouseRegion.offsetY, button)
    else
        for i = #self.mouseRegions, 2, -1 do -- 1 is this canvas, and mouse clicks should go through it
            local region = self.mouseRegions[i]

            if pointInRectangle(x, y, region.x, region.y, region.w, region.h) then
                region.element:mousereleased(x-region.offsetX, y-region.offsetY, button)

                return true
            end
        end
    end
end

function Gui3.Canvas:debugDraw()
    for i = 2, #self.mouseRegions do
        local region = self.mouseRegions[i]
        local r, g, b = region.element.debugColor:rgb()
        love.graphics.setColor(r, g, b, 0.5)
        love.graphics.rectangle("fill", region.x, region.y, region.w, region.h)
    end

    love.graphics.setColor(1, 1, 1, 1)
end