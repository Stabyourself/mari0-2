local component = {}

local MAXSPEED = 40
local ACCELERATION = 200

function component.setup(actor, dt, actorEvent, args)
    actor.shuffleDir = -1

    actor.maxSpeed = args["maxSpeed"] or MAXSPEED
    actor.acceleration = args["acceleration"] or ACCELERATION
    actor.speed[1] = actor.shuffleDir*MAXSPEED
end

function component.update(actor, dt)
    -- update shuffleDir if something (like portals) made us move the other way
    if actor.speed[1] > 0 then
        actor.shuffleDir = 1
    elseif actor.speed[1] < 0 then
        actor.shuffleDir = -1
    end

    actor:accelerateTo(dt, actor.shuffleDir*actor.maxSpeed, actor.maxSpeed)
end

function component.leftCollision(actor)
    actor.speed[1] = -actor.speed[1]
end

function component.rightCollision(actor)
    actor.speed[1] = -actor.speed[1]
end

return component