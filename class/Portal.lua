Portal = class("Portal")

function Portal:initialize(world, x1, y1, x2, y2, color)
    self.x1 = x1
    self.y1 = y1
    self.x2 = x2
    self.y2 = y2
    
    self.r = math.atan2(self.y2-self.y1, self.x2-self.x1)
    self.size = math.sqrt((self.x1-self.x2)^2 + (self.y1-self.y2)^2)
    
    self.color = color

    self.open = false
end

function Portal:draw()
    love.graphics.setColor(self.color)
    love.graphics.line(self.x1, self.y1, self.x2, self.y2)
end

function Portal:connectTo(portal)
    self.connectsTo = portal
    self.open = true
end