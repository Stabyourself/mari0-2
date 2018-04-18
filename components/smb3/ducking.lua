local component = {}

local BUTTACCELERATION = 225 -- this is per 1/8*pi of downhill slope
local FRICTIONBUTT = 277+7/9

function component.setup(actor)
    actor.ducking = false

    actor:registerState("buttSlide", function(actor)
        if cmdDown("right") or cmdDown("left") or (actor.speed[1] == 0 and actor.surfaceAngle == 0) then
            return "idle"
        end
    end)
end

function component.update(actor, dt)
    if actor.onGround then
        if cmdDown("down") and not cmdDown("left") and not cmdDown("right") and actor.state.name ~= "buttSlide" then
            if actor.surfaceAngle ~= 0 then -- check if buttslide
                actor:switchState("buttSlide")
                
                if actor.surfaceAngle > 0 then
                    actor.speed[1] = math.max(0, actor.speed[1])
                else
                    actor.speed[1] = math.min(0, actor.speed[1])
                end
            else
                actor.ducking = true
                
                -- Stop spinning in case
                actor.spinning = false
                actor.spinTimer = SPINTIME
            end
        else
            actor.ducking = false
        end
    end
    
    
    if actor.state.name == "buttSlide" then
        local buttAcceleration = BUTTACCELERATION * (actor.surfaceAngle/(math.pi/8))
        
        actor.speed[1] = actor.speed[1] + buttAcceleration*dt
        
        if actor.surfaceAngle == 0 then
            actor:friction(dt, FRICTIONBUTT)
        end
    end
end

return component
