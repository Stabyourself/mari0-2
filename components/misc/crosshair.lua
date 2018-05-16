local hasCrosshair = class("misc.hasCrosshair")

function hasCrosshair:initialize(actor, args)
    self.actor = actor
    self.args = args

    self:setup()
end

function hasCrosshair:setup()
    self.crosshair = DottedCrosshair:new(self.actor)
end

function hasCrosshair:postUpdate(dt)
    local x, y = self.actor.x+self.actor.width/2, self.actor.y+self.actor.height/2
    self.crosshair.origin.x = x
    self.crosshair.origin.y = y
    
    local mx, my = self.actor.world:mouseToWorld()
    
    self.crosshair.angle = math.atan2(my-y, mx-x)
    
    self.actor.portalGunAngle = self.crosshair.angle
    
    prof.push("Crosshair")
    self.crosshair:update(dt)
    prof.pop()
end

function hasCrosshair:draw()
    self.crosshair:draw()
end

return hasCrosshair
