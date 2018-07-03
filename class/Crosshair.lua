local Crosshair = class("Crosshair")

function Crosshair:initialize(obj)
    self.obj = obj
    self.target = {}
    self.origin = {}
    self.valid = false

    self.t = 0
end

function Crosshair:update(dt)
    self.t = self.t + dt

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
    if self.target.valid then
        if self.portalPossible then
            love.graphics.setColor(0, 1, 0)
        else
            love.graphics.setColor(1, 0, 0)
        end

        love.graphics.line(self.origin.x, self.origin.y, self.target.worldX, self.target.worldY)
    end
end

return Crosshair
