local Component = require "class.Component"
local DottedCrosshair = require("class.Crosshair").DottedCrosshair
local hasCrosshair = class("misc.hasCrosshair", Component)

function hasCrosshair:initialize(actor, args)
    Component.initialize(self, actor, args)

    self.crosshair = DottedCrosshair:new(self.actor)
end

function hasCrosshair:postUpdate(dt)
    local x, y = self.actor.x+self.actor.width/2, self.actor.y+self.actor.height/2
    self.crosshair.origin.x = x
    self.crosshair.origin.y = y

    local mx, my = self.actor.world:mouseToWorld()

    self.crosshair.angle = math.atan2(my-y, mx-x)

    self.actor.aimingAngle = self.crosshair.angle

    prof.push("Crosshair")
    self.crosshair:update(dt)
    prof.pop()
end

function hasCrosshair:draw()
    self.crosshair:draw()
end

return hasCrosshair
