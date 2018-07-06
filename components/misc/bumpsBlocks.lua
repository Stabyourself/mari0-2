local Component = require "class.Component"
local bumpsBlocks = class("misc.bumpsBlocks", Component)

function bumpsBlocks:topCollision(dt, actorEvent, obj2)
    if obj2.class == Physics3.Cell then
        self.actor.world:bumpBlock(obj2)
    end
end

return bumpsBlocks
