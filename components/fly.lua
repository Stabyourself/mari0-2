local component = {}

local FLYINGUPTIME = 16/60
local FLYTIME = 4.25
local MAXSPEEDFLY = 86.25
local FLYINGASCENSION = -90
local ACCELERATION = 196.875
local FRICTIONFLYSMALL = 56.25
local FRICTIONFLYBIG = 225
local FRICTIONSKIDFLY = 675 -- turnaround speed while flying

function component.setup(actor)
    actor:registerState("fly", function(actor, actorState)
        if not actor.flying then
            return "fall"
        end

        if actorState.timer >= FLYINGUPTIME then
            return "fall"
        end
    end)
end

function component.jump(actor)
    if not actor.wasOnGround then
        if actor.flying then
            actor.state:switch("fly")
        end

        if actor.pMeter == VAR("pMeterTicks") and not actor.flying then
            actor.flyTimer = 0
            actor.flying = true
        end
    end
end

function component.update(actor, dt)
    if actor.flying then
        actor.flyTimer = actor.flyTimer + dt
        
        if actor.flyTimer >= FLYTIME then
            actor.flying = false
            actor.pMeter = 0
        end
    end

    if actor.state.name == "fly" then
        if math.abs(actor.speed[1]) > MAXSPEEDFLY then
            if  actor.speed[1] > 0 and cmdDown("right") or
                actor.speed[1] < 0 and cmdDown("left") then
                actor:friction(dt, FRICTIONFLYSMALL, MAXSPEEDFLY)
            else
                actor:friction(dt, FRICTIONFLYBIG, MAXSPEEDFLY)
            end
        end
        
        accelerate(dt, actor, ACCELERATION, MAXSPEEDFLY)
        skid(dt, actor, FRICTIONSKIDFLY)

        actor.speed[2] = FLYINGASCENSION

        actor.gravity = 0
    end
end

function accelerate(dt, actor, acceleration, maxSpeed)
    if math.abs(actor.speed[1]) < maxSpeed then
        if cmdDown("left") and not cmdDown("right") and actor.speed[1] <= 0 then
            actor.speed[1] = math.max(-maxSpeed, actor.speed[1] - acceleration*dt)
        end

        if cmdDown("right") and not cmdDown("left") and actor.speed[1] >= 0 then
            actor.speed[1] = math.min(maxSpeed, actor.speed[1] + acceleration*dt)
        end
    end
end

function skid(dt, actor, friction)
    if cmdDown("right") and actor.speed[1] < 0 then
        actor.speed[1] = math.min(0, actor.speed[1] + friction*dt)
    end
    
    if cmdDown("left") and actor.speed[1] > 0 then
        actor.speed[1] = math.max(0, actor.speed[1] - friction*dt)
    end
end

return component
