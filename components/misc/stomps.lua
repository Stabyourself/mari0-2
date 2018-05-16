local stomps = class("misc.stomps")

function stomps:initialize(actor, args)
    self.actor = actor
    self.args = args

    self:setup()
end

function stomps:setup()
    -- todo: define a frame for "stomped"?
    self.actor.stompsLevel = self.args.level or 1
end

function stomps:bottomCollision(dt, actorEvent, obj2)
    if obj2.hasComponent and obj2:hasComponent("misc.stompable") then
        self.actor.y = obj2.y-self.actor.height
        self.actor.speed[2] = -getRequiredSpeed(VAR("enemyBounceHeight"))
        
        actorEvent:bind("after", function(actor)
            actor:switchState("fall") -- smb3.movement would love to set us to idle, but we can't have that
        end)

        actorEvent.returns = true

        obj2:event("getStomped")
        self.actor:event("stomp")
    end
end

return stomps
