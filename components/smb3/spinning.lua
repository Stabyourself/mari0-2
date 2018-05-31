local spinning = class("smb3.spinning")

local SPINTIME = 19/60

function spinning:initialize(actor, args)
    self.actor = actor
    self.args = args

    self:setup()
end

function spinning:setup()
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
    if not self.actor.spinning and not cmdDown("down") then -- Make sure it's not colliding with any of the other states
        self.actor.spinning = true
        self.actor.spinTimer = 0
        self.actor.spinDirection = self.actor.animationDirection
    end
end

return spinning
