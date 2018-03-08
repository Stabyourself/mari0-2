local component = {}

local MAXSPEED = 40
local ACCELERATION = 200

function component.setup(actor)
    actor.shuffleDir = 1
    -- actor.speed[1] = actor.shuffleDir*MAXSPEED
end

function component.update(actor, dt)
    -- update shuffleDir if something (like portals) made us move the other way

    if actor.speed[1] > 0 then
        actor.shuffleDir = 1
    elseif actor.speed[1] < 0 then
        actor.shuffleDir = -1
    end

    actor:accelerateTo(dt, actor.shuffleDir*MAXSPEED, ACCELERATION)
end

function component.leftCollision(actor)
    actor.speed[1] = -actor.speed[1]
end

function component.rightCollision(actor)
    actor.speed[1] = -actor.speed[1]
end

return component