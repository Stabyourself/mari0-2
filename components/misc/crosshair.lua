local crosshair = class("misc.crosshair")

function crosshair:initialize(actor, args)
    self.actor = actor
    self.args = args

    self:setup()
end

function crosshair:setup()
    self.actor.crosshair = DottedCrosshair:new(self.actor)
end

function crosshair:postUpdate(dt)
    local x, y = self.actor.x+self.actor.width/2, self.actor.y+self.actor.height/2
    self.actor.crosshair.origin.x = x
    self.actor.crosshair.origin.y = y
    
    local mx, my = self.actor.world:mouseToWorld()
    
    self.actor.crosshair.angle = math.atan2(my-y, mx-x)
    
    self.actor.portalGunAngle = self.actor.crosshair.angle
    
    prof.push("Crosshair")
    self.actor.crosshair:update(dt)
    prof.pop()
end

function crosshair:draw()
    self.actor.crosshair:draw()
end

return crosshair
