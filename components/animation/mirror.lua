local mirror = class("animation.mirror")

local MIRRORTIME = 0.2

function mirror:initialize(actor, args)
    self.actor = actor
    self.args = args

    self:setup()
end

function mirror:setup()
    self.mirrorTime = self.args["time"] or MIRRORTIME
    self.mirrorTimer = 0
end

function mirror:update(dt)
    self.mirrorTimer = self.mirrorTimer + dt

    while self.mirrorTimer > self.mirrorTime do
        self.mirrorTimer = self.mirrorTimer - self.mirrorTime
        
        self.actor.animationDirection = -self.actor.animationDirection
    end
end

return mirror