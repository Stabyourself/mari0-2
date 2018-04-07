local component = {}

local SPINTIME = 19/60

function component.setup(actor)
    actor.spinning = false
    actor.spinTimer = SPINTIME
end

function component.update(actor, dt)
    if actor.spinning then
        actor.spinTimer = actor.spinTimer + dt
        
        if actor.spinTimer >= SPINTIME then
            actor.spinning = false
        end
    end
end

function component.action(actor)
    if not actor.spinning and not cmdDown("down") then -- Make sure it's not colliding with any of the other states
        actor.spinning = true
        actor.spinTimer = 0
        actor.spinDirection = actor.animationDirection
    end
end

return component
