local Gui3 = ...
Gui3.Canvas = class("Gui3.Canvas", Gui3.Element)

Gui3.Canvas.movesToFront = true

function Gui3.Canvas:initialize(x, y, w, h)
    Gui3.Element.initialize(self, x, y, w, h)

    self.children = {}
    self.background = {0, 0, 0, 0}
    self.mouseRegions = {}
    self.lastMouseRegion = nil

    self.lastMouseX = 0
    self.lastMouseY = 0

    self.mouseRegionsOutdated = true
end

function Gui3.Canvas:draw()
    love.graphics.setColor(self.background)
    love.graphics.rectangle("fill", 0, 0, self.w, self.h)

    Gui3.Element.draw(self)
end

function Gui3.Canvas:updateMouseRegions()
    self.mouseRegionsOutdated = true
end

function Gui3.Canvas:update(dt)
    if self.mouseRegionsOutdated then
        if VAR("debug").reMouses then
            print("Remouse @ " .. love.timer.getTime())
        end

        prof.push("getMouseZone")
        local lastIndex = self:getMouseZone(self.mouseRegions, 1, 0, 0, 0, 0, self.w, self.h)
        prof.pop("getMouseZone")

        for i = #self.mouseRegions, lastIndex, -1 do
            self.mouseRegions[i] = nil
        end

        self.mouseRegionsOutdated = false
        self.recheckMouse = true
    end
end

function Gui3.Canvas:rootmousemoved(x, y)
    local diffX = x-self.lastMouseX
    local diffY = y-self.lastMouseY

    if diffX ~= 0 or diffY ~= 0 or self.recheckMouse then
        self.recheckMouse = false
        self.lastMouseX = x
        self.lastMouseY = y

        if self.lastMouseRegion then
            self.lastMouseRegion.element:mousemoved(x-self.lastMouseRegion.offsetX, y-self.lastMouseRegion.offsetY, diffX, diffY)
        end

        if not self.lastMouseRegion or not self.lastMouseRegion.element.exclusiveMouse then
            for i = #self.mouseRegions, 2, -1 do -- 1 is this canvas, and mouse clicks should go through it
                local region = self.mouseRegions[i]

                if pointInRectangle(x, y, region.x, region.y, region.w, region.h) then
                    if not self.lastMouseRegion or region.element ~= self.lastMouseRegion.element then
                        if self.lastMouseRegion then
                            self.lastMouseRegion.element:mouseleft(x-self.lastMouseRegion.offsetX, y-self.lastMouseRegion.offsetY)
                        end

                        region.element:mouseentered(x-region.offsetX, y-region.offsetY)
                        region.element:mousemoved(x-region.offsetX, y-region.offsetY, 0, 0)

                        self.lastMouseRegion = region
                    end

                    return true
                end
            end
            -- no region was entered
            if self.lastMouseRegion then
                self.lastMouseRegion.element:mouseleft(x-self.lastMouseRegion.offsetX, y-self.lastMouseRegion.offsetY)
                self.lastMouseRegion = nil
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
    if self.lastMouseRegion and self.lastMouseRegion.element.exclusiveMouse then
        self.lastMouseRegion.element:mousereleased(x-self.lastMouseRegion.offsetX, y-self.lastMouseRegion.offsetY, button)
        if not pointInRectangle(x, y, self.lastMouseRegion.x, self.lastMouseRegion.y, self.lastMouseRegion.w, self.lastMouseRegion.h) then -- mouse left the region since
            self.lastMouseRegion.element:mouseleft(x-self.lastMouseRegion.offsetX, y-self.lastMouseRegion.offsetY, button)
            self.lastMouseRegion = nil

            for i = #self.mouseRegions, 2, -1 do -- 1 is this canvas, and mouse clicks should go through it
                local region = self.mouseRegions[i]

                if pointInRectangle(x, y, region.x, region.y, region.w, region.h) then
                    region.element:mouseentered(x-region.offsetX, y-region.offsetY)
                    region.element:mousemoved(x-region.offsetX, y-region.offsetY, 0, 0)
                    self.lastMouseRegion = region

                    return true
                end
            end
        end
    else
        for i = 2, #self.mouseRegions do -- 1 is this canvas, and mouse clicks should go through it
            local region = self.mouseRegions[i]

            if not pointInRectangle(x, y, region.x, region.y, region.w, region.h) then
                region.element:blur()
            end
        end

        for i = #self.mouseRegions, 2, -1 do -- 1 is this canvas, and mouse clicks should go through it
            local region = self.mouseRegions[i]

            if pointInRectangle(x, y, region.x, region.y, region.w, region.h) then
                region.element:mousereleased(x-region.offsetX, y-region.offsetY, button)

                return true
            end
        end
    end
end

function Gui3.Canvas:rootwheelmoved(x, y)
    local mouseX, mouseY = game.level:getMouse()

    for i = #self.mouseRegions, 2, -1 do -- 1 is this canvas, and mouse clicks should go through it
        local region = self.mouseRegions[i]

        if pointInRectangle(mouseX, mouseY, region.x, region.y, region.w, region.h) then
            region.element:wheelmoved(x, y)

            return true
        end
    end
end

function Gui3.Canvas:debugDraw()
    for i = 2, #self.mouseRegions do
        local region = self.mouseRegions[i]
        local r, g, b = region.element.debugColor:rgb()
        love.graphics.setColor(r, g, b, 0.5)
        love.graphics.rectangle("fill", region.x*VAR("scale"), region.y*VAR("scale"), region.w*VAR("scale"), region.h*VAR("scale"))
    end

    love.graphics.setColor(1, 1, 1, 1)
end