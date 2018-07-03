local Component = require "class.Component"
local mirror = class("animation.mirror", Component)

mirror.argList = {
    {"time", "number", 0.2},
}

function mirror:initialize(actor, args)
    Component.initialize(self, actor, args)

    self.mirrorTimer = 0
end

function mirror:update(dt)
    self.mirrorTimer = self.mirrorTimer + dt

    while self.mirrorTimer > self.time do
        self.mirrorTimer = self.mirrorTimer - self.time

        self.actor.animationDirection = -self.actor.animationDirection
    end
end

return mirror
