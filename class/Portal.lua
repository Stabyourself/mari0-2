Portal = class("Portal")

Portal.size = 2

function Portal:initialize(world, x, y, r, color)
    self.x = x
    self.y = y
    self.r = r
    self.color = color

    self.x1 = x
    self.y1 = y
    self.x2 = x+math.cos(self.r)*self.size
    self.y2 = y+math.sin(self.r)*self.size

    self.open = true
    
    self.portalWalls = {
        PortalWall:new(world, self.x1, self.y1),
        PortalWall:new(world, self.x2, self.y2)
    }
end

function Portal:updateWallPositions()
    self.portalWalls[1].x = self.x1
    self.portalWalls[1].y = self.y1

    self.portalWalls[2].x = self.x2
    self.portalWalls[2].y = self.y2
end

function Portal:draw()
    love.graphics.setColor(self.color)
    worldLine(self.x1, self.y1, self.x2, self.y2)
end