local Cell = class("Physics3.Cell")
Cell:include(Physics3collisionMixin)

Cell.bounceTime = 10/60
Cell.bounceHeight = 10

function Cell.bounceEase(t, b, c, d)
    if t < d/2 then
        return Easing.outQuad(t, b, c, d/2)
    else
        return Easing.inQuad(t-d/2, c, b-c, d/2)
    end
end

function Cell:initialize(x, y, layer, tile)
    self.x = x
    self.y = y
    self.layer = layer
    self.tile = tile

    self.bounceTimer = self.bounceTime
end

function Cell:update(dt)
    if self.bounceTimer < self.bounceTime then
        self.bounceTimer = math.min(self.bounceTime, self.bounceTimer + dt)

        return self.bounceTimer >= self.bounceTime
    end
end

function Cell:draw()
    if self.tile then
        local off = 0

        if self.bounceTimer < self.bounceTime then
            off = self.bounceEase(self.bounceTimer, 0, 1, self.bounceTime)
        end

        self.tile:draw((self.x-1)*16, (self.y-1)*16-off*self.bounceHeight)
    end
end

function Cell:drawFrame(frame)
    if self.tile then
        local off = 0

        if self.bounceTimer < self.bounceTime then
            off = self.bounceEase(self.bounceTimer, 0, 1, self.bounceTime)
        end

        self.tile:drawFrame((self.x-1)*16, (self.y-1)*16-off*self.bounceHeight, frame)
    end
end

function Cell:bounce()
    self.bounceTimer = 0
end

return Cell
