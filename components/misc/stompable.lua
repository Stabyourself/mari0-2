local component = {}

function component.setup(actor, dt, actorEvent, args)
    actor.stompAble = true
    actor.stompAbleLevel = args.level or 1
end

function component.getStomped(actor)
    -- uh something
end

return component
