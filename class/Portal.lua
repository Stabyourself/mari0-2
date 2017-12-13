Portal = class("Portal")

Portal.size = 32

function Portal:initialize(world, x, y, r, color)
    self.x = x
    self.y = y
    self.r = r
    self.color = color

    self.x1 = x
    self.y1 = y
    self.x2 = x+math.cos(self.r)*self.size
    self.y2 = y+math.sin(self.r)*self.size

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