local component = {}

function component.update(actor, dt)
    if CHEAT("tumble") then
        actor.angle = actor.angle + actor.speed[1]*dt*0.1
        actor:unRotate(0)
    else
        actor:unRotate(dt)
    end
end

return component
