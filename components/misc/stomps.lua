local component = {}

function component.setup(actor, dt, actorEvent, args)
    -- todo: define a frame for "stomped"?
    actor.stompsLevel = args.level or 1
    actor.goingup = false
end

function component.bottomCollision(actor, dt, actorEvent, args, obj2)
    if obj2.stompAble then
        actor.y = obj2.y-actor.height
        actor.speed[2] = -getRequiredSpeed(VAR("enemyBounceHeight"))
        
        actorEvent:bind("after", function(actor)
            actor:switchState("fall") -- smb3.movement would love to set us to idle, but we can't have that
        end)

        actorEvent.returns = true

        obj2:event("getStomped")
        actor:event("stomp")
    end
end

return component
