local kicks = class("misc.kicks")

function kicks:initialize(actor, args)
    self.actor = actor
end

function kicks:leftCollision(dt, actorEvent, obj2)
    if obj2:hasComponent("misc.kickable") and obj2.speed[1] == 0 then
        obj2:event("kicked", 0, -1)
        actorEvent.returns = true
    end
end

function kicks:rightCollision(dt, actorEvent, obj2)
    if obj2:hasComponent("misc.kickable") and obj2.speed[1] == 0 then
        obj2:event("kicked", 0, 1)
        actorEvent.returns = true
    end
end

function kicks:bottomCollision(dt, actorEvent, obj2)
    if obj2:hasComponent("misc.kickable") then
        if obj2.speed[1] == 0 then -- kick it
            local selfX = self.actor.x + self.actor.width*.5
            local obj2X = obj2.x + obj2.width*.5

            local dir = 1

            if selfX > obj2X then
                dir = -1
            end

            if dir == 1 then
                obj2.x = self.actor.x + self.actor.width
            else
                obj2.x = self.actor.x - obj2.width
            end

            obj2:event("kicked", 0, dir)

        else -- stop it
            self.actor.y = obj2.y-self.actor.height
            self.actor.speed[2] = -getRequiredSpeed(VAR("enemyBounceHeight"))
        
            actorEvent:bind("after", function(actor)
                actor:switchState("fall") -- smb3.movement would love to set us to idle, but we can't have that
            end)
    
            obj2:event("unkicked")
        end -- bop it

        actorEvent.returns = true
    end
end

return kicks