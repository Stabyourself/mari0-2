local component = {}

local ACCELERATION = 196.875 -- acceleration on ground

local JUMPGRAVITYUNTIL = -120

local MAXSPEEDS = {90, 150, 210}

local FRICTION = 140.625 -- amount of speed that is substracted when not pushing buttons
local FRICTIONICE = 42.1875 -- duh
local FRICTIONFLYSMALL = 56.25
local FRICTIONFLYBIG = 225

local FRICTIONSKID = 450 -- turnaround speed
local FRICTIONSKIDFLY = 675 -- turnaround speed while flying
local FRICTIONSKIDICE = 182.8125 -- turnaround speed on ice

local PMETERTIMEUP = 8/60
local PMETERTIMEDOWN = 24/60
local PMETERTIMEMARGIN = 16/60

local DOWNHILLWALKBONUS = 7.5

local state = {}


function component.setup(actor)
    actor.jumping = false
    

    actor.animationState = "idle"
    
    actor.animationDirection = 1
    
    actor.pMeter = 0
    actor.pMeterTimer = 0
    actor.pMeterTime = 8/60
    
    actor.runAnimationFrame = 1
    actor.runAnimationTimer = 0
    
    actor.flyAnimationFrame = 1
    actor.flyAnimationTimer = 0
    
    actor.somerSaultFrame = 2
    actor.somerSaultFrameTimer = 0
    
    actor.spinning = false
    actor.spinTimer = SPINTIME
    
    actor.shooting = false
    actor.shootTimer = 0
    
    actor:registerState("idle", function(actor)
        if cmdDown("right") or cmdDown("left") then
            return "run"
        end
        
        if actor.speed[1] ~= 0 then
            return "stop"
        end
    end)


    actor:registerState("stop", function(actor)
        if cmdDown("right") or cmdDown("left") then
            return "run"
        end
        
        if actor.speed[1] == 0 then
            return "idle"
        end
    end)


    actor:registerState("run", function(actor)
        if not cmdDown("right") and not cmdDown("left") then
            return "stop"
        end
        
        if  actor.speed[1] > 0 and cmdDown("left") or
            actor.speed[1] < 0 and cmdDown("right") then
            return "skid"
        end
    end)


    actor:registerState("skid", function(actor)
        if actor.speed[1] == 0 then
            return "idle"
        end
        
        if  (actor.speed[1] < 0 and cmdDown("left") and not cmdDown("right")) or
            (actor.speed[1] > 0 and cmdDown("right") and not cmdDown("right")) or
            (actor.speed[1] > 0 and not cmdDown("left")) or
            (actor.speed[1] < 0 and not cmdDown("right")) then
            return "run"
        end
    end)


    actor:registerState("fall", function(actor)
        if cmdDown("jump") and actor.speed[2] < JUMPGRAVITYUNTIL then
            return "jump"
        end
        -- handled by bottomCollision
    end)

    actor.state = ActorState:new(actor, "idle", actor.states.idle) -- maybe change this
end

function component.update(actor, dt, actorEvent)
    if actor.world.controlsEnabled then
        movement(actor, dt, actorEvent)
    end
end

function movement(actor, dt, actorEvent)
    -- if not friction then
    --     if somethingIce then -- todo
    --         friction = FRICTIONICE
    --     else
    --         friction = FRICTION
    --     end
    -- end

    if actor.starMan then
        actor.starTimer = actor.starTimer + dt
        
        if actor.starTimer >= STARTIME then
            actor.starMan = false
            actor.img = actor.graphics["small"].img
            actor.palette = actor.standardPalette
        end
        
        if actor.graphics["small"].frames.somerSault then
            actor.somerSaultFrameTimer = actor.somerSaultFrameTimer + dt
            
            while actor.somerSaultFrameTimer > SOMERSAULTTIME do
                actor.somerSaultFrameTimer = actor.somerSaultFrameTimer - SOMERSAULTTIME
                
                actor.somerSaultFrame = actor.somerSaultFrame + 1
                if actor.somerSaultFrame > actor.graphics["small"].frames.somerSault then
                    actor.somerSaultFrame = 1
                end
            end
        end
    end
    
    if actor.shooting then
        actor.shootTimer = actor.shootTimer + dt
        
        if actor.shootTimer >= SHOOTTIME then
            actor.shooting = false
        end
    end
    
    if actor.spinning then
        actor.spinTimer = actor.spinTimer + dt
        
        if actor.spinTimer >= SPINTIME then
            actor.spinning = false
        end
    end
    
    if actor.state.name == "idle" then
        
    end
    
    if actor.state.name == "stop" then
        actor:friction(dt, FRICTION)
    end
    
    if actor.state.name == "run" then
        local maxSpeed = 0
        
        if cmdDown("left") or cmdDown("right") then
            maxSpeed = MAXSPEEDS[1]
        end
        
        if cmdDown("run") then
            maxSpeed = MAXSPEEDS[2]
        end
        
        if actor.pMeter == VAR("pMeterTicks") and cmdDown("run") then
            maxSpeed = MAXSPEEDS[3]
        end
        
        if not actor.onGround then
            maxSpeed = actor.maxSpeedJump or MAXSPEEDS[1]
        end
    
        -- Normal left/right acceleration
        accelerate(dt, actor, ACCELERATION, maxSpeed)
        
        if math.abs(actor.speed[1]) > maxSpeed then
            actor:friction(dt, FRICTION)
        end
    end
    
    if actor.state.name == "skid" then
        skid(dt, actor, FRICTIONSKID)
    end
    
    if not actor.flying and (actor.state.name == "jump" or actor.state.name == "fall") then
        accelerate(dt, actor, ACCELERATION, actor.maxSpeedJump or MAXSPEEDS[1])
        skid(dt, actor, FRICTIONSKID)
    end
    
    -- P meter
    actor.pMeterTimer = actor.pMeterTimer + dt
    
    if actor.speed[1] == MAXSPEEDS[2] and actor.pMeter == 0 then
        actor.pMeterTime = PMETERTIMEUP
        actor.pMeterTimer = PMETERTIMEUP
    end
    
    -- Maintain fullspeed when pMeter full
    if actor.pMeter == VAR("pMeterTicks") and
        (not actor.onGround or 
        (math.abs(actor.speed[1]) >= MAXSPEEDS[2] and
        cmdDown("run") and 
        ((actor.speed[1] > 0 and cmdDown("right")) or (actor.speed[1] < 0 and cmdDown("left"))))) then
        actor.pMeterTimer = 0
        actor.pMeterTime = PMETERTIMEMARGIN
    end
    
    if not actor.flying then
        while actor.pMeterTimer >= actor.pMeterTime do
            actor.pMeterTimer = actor.pMeterTimer - actor.pMeterTime
            
            if actor.onGround and math.abs(actor.speed[1]) >= MAXSPEEDS[2] then
                if actor.pMeter < VAR("pMeterTicks") then
                    actor.pMeterTime = PMETERTIMEUP
                    actor.pMeter = actor.pMeter + 1
                end
            else
                if actor.pMeter > 0 then
                    actor.pMeterTime = PMETERTIMEDOWN
                    actor.pMeter = actor.pMeter - 1
                    
                    if actor.pMeter == 0 then
                        actor.pMeterTime = PMETERTIMEUP
                    end
                end
            end
        end
    end

    if CHEAT("infinitePMeter") then
        actor.pMeter = VAR("pMeterTicks")
        actor.flyTimer = 0
    end
    
    
    -- actor.speed[1] = actor.groundSpeedX
    
    -- Adjust speed[1] if going downhill or uphill
    -- if actor.onGround then
    --     if actor.surfaceAngle > 0 then
    --         if actor.groundSpeedX > 0 then
    --             actor.speed[1] = actor.speed[1] + DOWNHILLWALKBONUS
    --         else
    --             actor.speed[1] = actor.speed[1] * math.cos(actor.surfaceAngle)
    --         end
    --     elseif actor.surfaceAngle < 0 then
    --         if actor.groundSpeedX < 0 then
    --             actor.speed[1] = actor.speed[1] - DOWNHILLWALKBONUS
    --         else
    --             actor.speed[1] = actor.speed[1] * math.cos(-actor.surfaceAngle)
    --         end
    --     end
    -- end

    
    -- Update gravity
    actorEvent:setValue("gravity", VAR("gravity"), 0)
end

function component.bottomCollision(actor)
    if actor.state.name == "jump" or actor.state.name == "fall" then
        actor.state:switch("idle")
    end
end

function component.startFall(actor)
    actor.state:switch("fall")
end

function skid(dt, actor, friction)
    if cmdDown("right") and actor.speed[1] < 0 then
        actor.speed[1] = math.min(0, actor.speed[1] + friction*dt)
    end
    
    if cmdDown("left") and actor.speed[1] > 0 then
        actor.speed[1] = math.max(0, actor.speed[1] - friction*dt)
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

return component
