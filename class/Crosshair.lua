local Crosshair = class("Crosshair")

function Crosshair:initialize(obj)
    self.obj = obj
    self.target = {}
    self.origin = {}
    self.valid = false

    self.t = 0
end

function Crosshair:update(dt)
    prof.push("Raycast")
    local layer, tileX, tileY, worldX, worldY, blockSide = self.obj.world:rayCast(
        self.origin.x/self.obj.world.tileSize,
        self.origin.y/self.obj.world.tileSize,
        self.angle
    )
    prof.pop()

    if layer then
        worldX, worldY = self.obj.world:coordinateToWorld(worldX, worldY)

        self.target.valid = true
        self.target.layer = layer
        self.target.tileX = tileX
        self.target.tileY = tileY
        self.target.worldX = worldX
        self.target.worldY = worldY
        self.target.blockSide = blockSide

        self.length = math.sqrt((self.origin.x-self.target.worldX)^2 + (self.origin.y-self.target.worldY)^2)

        self.target.portalPossible = false

        prof.push("CheckPortalSurface")
        local x1, y1, x2, y2, angle = self.obj.world:checkPortalSurface(
            self.target.layer,
            self.target.tileX,
            self.target.tileY,
            self.target.blockSide,
            self.target.worldX,
            self.target.worldY
        )
        prof.pop()


        if x1 then
            self.target.angle = angle

            local length = math.sqrt((x1-x2)^2+(y1-y2)^2)

            if length >= VAR("portalSize") then
                self.target.portalPossible = true
            end
        else -- Map boundary?
            if blockSide == 1 then
                self.target.angle = 0
            elseif blockSide == 2 then
                self.target.angle = math.pi*0.5
            elseif blockSide == 3 then
                self.target.angle = math.pi
            elseif blockSide == 4 then
                self.target.angle = math.pi*1.5
            end
        end
    else
        self.target.portalPossible = false
        self.target.valid = false
    end
end

function Crosshair:draw()

end



local LineCrosshair = class("LineCrosshair", Crosshair)

function LineCrosshair:draw()
    if self.target.valid then
        if self.portalPossible then
            love.graphics.setColor(0, 1, 0)
        else
            love.graphics.setColor(1, 0, 0)
        end

        love.graphics.line(self.origin.x, self.origin.y, self.target.worldX, self.target.worldY)
    end
end



local DottedCrosshair = class("DottedCrosshair", Crosshair)

DottedCrosshair.targetImg = love.graphics.newImage("img/crosshair-target.png")

DottedCrosshair.dotDistance = 16
DottedCrosshair.dotSize = 1
DottedCrosshair.fadeInDistance = 16
DottedCrosshair.fadeInLength = 12

function DottedCrosshair:initialize(actor)
    self.t = 0

    Crosshair.initialize(self, actor)
end

function DottedCrosshair:update(dt)
    self.t = self.t + dt

    Crosshair.update(self, dt)
end

function DottedCrosshair:draw()
    if not self.target.valid then
        return
    end

    local dotCount = (self.length+self.dotSize)/self.dotDistance

    for i = 0, dotCount do
        local factor = 1/dotCount*(i+self.t%1)

        if factor <= 1 - (self.dotSize/2)/self.length then
            local x = self.origin.x+(self.target.worldX-self.origin.x)*factor
            local y = self.origin.y+(self.target.worldY-self.origin.y)*factor

            local a = math.clamp(((factor*(self.length+self.dotSize))-self.fadeInDistance)/self.fadeInDistance, 0, 1)

            if self.target.portalPossible then
                love.graphics.setColor(0, 0.88, 0, a)
            else
                love.graphics.setColor(1, 0, 0, a)
            end

            love.graphics.rectangle("fill", x-self.dotSize/2, y-self.dotSize/2, self.dotSize, self.dotSize)
        end
    end

    if self.target.portalPossible then
        love.graphics.setColor(0, 0.88, 0, a)
    else
        love.graphics.setColor(1, 0, 0, a)
    end

    love.graphics.draw(self.targetImg, self.target.worldX, self.target.worldY, self.target.angle, 1, 1, 4, 8)
end

return {Crosshair = Crosshair, LineCrosshair = LineCrosshair, DottedCrosshair = DottedCrosshair}
