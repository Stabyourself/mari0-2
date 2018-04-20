local component = {}

local STARTIME = 7.5

function component.setup(actor)
    actor.starred = true
    actor.starTimer = 0
    actor.somerSaultFrame = 2
    actor.somerSaultFrameTimer = 0
end

function component.update(actor, dt, actorEvent)
    actor.starTimer = actor.starTimer + dt
    
    if actor.starTimer >= STARTIME then
        actor.palette = actor.defaultPalette
        actor.starred = false
    end
end

function component.jump(actor)
    if actor.onGround then
        actor.somerSaultFrame = 2
        actor.somerSaultFrameTimer = 0
    end
end

return component
