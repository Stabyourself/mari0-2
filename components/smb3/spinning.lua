local Component = require "class.Component"
local spinning = class("smb3.spinning", Component)

local SPINTIME = 19/60

function spinning:initialize(actor, args)
    Component.initialize(self, actor, args)

    self.actor.spinning = false
    self.actor.spinTimer = SPINTIME
end

function spinning:update(dt)
    if self.actor.spinning then
        self.actor.spinTimer = self.actor.spinTimer + dt

        if self.actor.spinTimer >= SPINTIME then
            self.actor.spinning = false
        end
    end
end

function spinning:action()
    if not self.actor.spinning and not controls3.cmdDown("down") and not self.actor.underWater then -- Make sure it's not colliding with any of the other states
        self.actor.spinning = true
        self.actor.spinTimer = 0
        self.actor.spinDirection = self.actor.animationDirection
    end
end

return spinning
