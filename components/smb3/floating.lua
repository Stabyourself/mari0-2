local component = {}

local FLOATASCENSION = 60
local FLOATTIME = 16/60

local MAXSPEEDFLY = 86.25
local ACCELERATION = 196.875
local FRICTIONFLYSMALL = 56.25
local FRICTIONFLYBIG = 225
local FRICTIONSKIDFLY = 675 -- turnaround speed while flying

function component.setup(actor)
    actor.floatAnimationFrame = 1
    actor.floatAnimationTimer = 0

    actor:registerState("float", function(actor, actorState)
        if actorState.timer >= FLOATTIME then
            return "fall"
        end
    end)
end

function component.update(actor, dt)
    if actor.state.name == "float" then
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

        actor.speed[2] = FLOATASCENSION
    end
end

function component.jump(actor)
    if not actor.flying and not actor.onGround and actor.speed[2] > 0 then
        actor.state:switch("float")
        actor.floatAnimationTimer = 0
        actor.floatAnimationFrame = 1
    end
end

function component.bottomCollision(actor)
    if actor.state.name == "float" then
        actor.state:switch("idle")
    end
end

return component
