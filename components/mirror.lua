local component = {}

local MIRRORTIME = 0.2

function component.setup(actor)
    actor.img = actor.actorTemplate.img

    if actor.actorTemplate.sizeX then
        actor.centerX = actor.actorTemplate.sizeX
        actor.centerY = actor.actorTemplate.sizeY
    else
        actor.sizeX = actor.img:getWidth()
        actor.sizeY = actor.img:getHeight()
    end

    if actor.actorTemplate.centerX then
        actor.centerX = actor.actorTemplate.centerX
        actor.centerY = actor.actorTemplate.centerY
    else
        actor.centerX = actor.img:getWidth()/2
        actor.centerY = actor.img:getHeight()/2
    end

    actor.mirrorTimer = 0
    actor.animationDirection = 1
end

function component.update(actor, dt)
    actor.mirrorTimer = actor.mirrorTimer + dt

    while actor.mirrorTimer > MIRRORTIME do
        actor.mirrorTimer = actor.mirrorTimer - MIRRORTIME
        
        actor.animationDirection = -actor.animationDirection
    end
end

return component