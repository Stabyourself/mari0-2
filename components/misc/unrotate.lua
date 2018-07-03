local Component = require "class.Component"
local unrotate = class("misc.unrotate", Component)

function unrotate:update(dt)
    if CHEAT("tumble") then
        self.actor.angle = self.actor.angle + self.actor.speed[1]*dt*0.1
        self.actor:unRotate(0)
    else
        self.actor:unRotate(dt)
    end
end

return unrotate
