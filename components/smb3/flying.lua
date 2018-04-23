local component = {}

local FLYINGUPTIME = 16/60
local FLYTIME = 4.25
local MAXSPEEDFLY = 86.25
local MAXSPEEDS = {90, 150, 210}
local FLYINGASCENSION = -90
local ACCELERATION = 196.875
local FRICTIONFLYSMALL = 56.25
local FRICTIONFLYBIG = 225
local FRICTIONSKIDFLY = 675 -- turnaround speed while flying

function component.setup(actor)
    actor.flyTimer = FLYTIME
    actor.flying = false
    
    actor.flyAnimationFrame = 1
    actor.flyAnimationTimer = 0

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
    if not actor.onGround and actor.flying then
        actor:switchState("fly")
        actor.flyAnimationFrame = 1
    end

    if actor.pMeter == VAR("pMeterTicks") and not actor.flying then
        actor.flyTimer = 0
        actor.flying = true
    end
end

function component.update(actor, dt, actorEvent)
    if actor.flying then
        actor.flyTimer = actor.flyTimer + dt
        
        if actor.flyTimer >= FLYTIME then
            actor.flying = false
            actor.pMeter = 0
        end
    end

    if  (actor.flying and (actor.state.name == "jump" or actor.state.name == "fall")) or
        actor.state.name == "fly" then
        if math.abs(actor.speed[1]) > MAXSPEEDFLY then
            if  actor.speed[1] > 0 and cmdDown("right") or
                actor.speed[1] < 0 and cmdDown("left") then
                actor:friction(dt, FRICTIONFLYSMALL, MAXSPEEDFLY)
            else
                actor:friction(dt, FRICTIONFLYBIG, MAXSPEEDFLY)
            end
        end
        
        if actor.state.name == "fly" then
            accelerate(dt, actor, ACCELERATION, MAXSPEEDFLY)
            actor.speed[2] = FLYINGASCENSION
            actorEvent:setValue("gravity", 0, 10)
        else
            local maxSpeed = math.min(MAXSPEEDS[2], actor.maxSpeedJump or MAXSPEEDS[1])
            
            accelerate(dt, actor, ACCELERATION, maxSpeed)
        end

        skid(dt, actor, FRICTIONSKIDFLY)
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
