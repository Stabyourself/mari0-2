local character = {}

local WALKACCELERATION = 196.875 --acceleration of walking on ground
local RUNACCELERATION = 256 --acceleration of running on ground

local MINSPEED = 0 --When FRICTION is in effect and speed falls below this, speed is set to 0
local MAXWALKSPEED = 90 --fastest speedx when walking
local MAXRUNSPEED = 150 --fastest speedx when running
local MAXSPRINTSPEED = 210 --fastest speedx when sprinting (P-meter full)

local FRICTION = 125 --amount of speed that is substracted when not pushing buttons
local FRICTIONICE = 42.1875 --duh

local FRICTIONSKID = 450 --turnaround speed
local FRICTIONSKIDICE = 182.8125 --turnaround speed on ice

local RUNANIMATIONTIME = 1.6 --

local JUMPFORCE = 256
local JUMPFORCEADD = 30.4 --how much jumpforce is added at top speed (linear from 0 to topspeed)

character.runFrames = 2

function character.movement(dt, mario)
    --Todo: Don't accelerate past maxwalkspeed in air!
    --Todo: Some stuff about automatically getting maxrunspeed if on maxwalkspeed when landing
    local acceleration = 0

    -- Normal left/right acceleration
    if (not keyDown("run") and math.abs(mario.speedX) <= MAXWALKSPEED) or (keyDown("run") and math.abs(mario.speedX) <= MAXRUNSPEED) then
        local accelerationVal = WALKACCELERATION
        if keyDown("run") then
            accelerationVal = RUNACCELERATION
        end

        if keyDown("left") and mario.speedX <= 0 then
            acceleration = acceleration - accelerationVal
        end

        if keyDown("right") and mario.speedX >= 0 then
            acceleration = acceleration + accelerationVal
        end
    end

    -- Apply friction?
    if  (not keyDown("right") and not keyDown("left")) or 
        (mario.ducking and mario.onGround) or
        mario.disabled or
        (not keyDown("run") and math.abs(mario.speedX) > MAXWALKSPEED) or
        math.abs(mario.speedX) > MAXRUNSPEED then
            
        if mario.speedX > 0 then
            acceleration = acceleration - FRICTION
        elseif mario.speedX < 0 then
            acceleration = acceleration + FRICTION
        end
    end
    
    if keyDown("right") and mario.speedX < 0 then
        acceleration = acceleration + FRICTIONSKID
    end
    
    if keyDown("left") and mario.speedX > 0 then
        acceleration = acceleration - FRICTIONSKID
    end

    -- Clamp max speeds for walk and run
    local maxSpeed

    if (not keyDown("run") and math.abs(mario.speedX) < MAXWALKSPEED) then
        maxSpeed = MAXWALKSPEED
    elseif (keyDown("run") and math.abs(mario.speedX) < MAXRUNSPEED) then
        maxSpeed = MAXRUNSPEED
    end
    
    local oldSpeedX = mario.speedX
    mario.speedX = mario.speedX + acceleration*dt
    
    -- Stop mario completely if going over 0 with no direction held
    if not keyDown("left") and not keyDown("right") and 
        ((mario.speedX > 0 and oldSpeedX < 0) or (mario.speedX < 0 and oldSpeedX > 0)) then
        mario.speedX = 0
    end
    
    -- Stop mario from going over runspeed by simply accelerating
    if (keyDown("left") or keyDown("right")) and 
        ((mario.speedX >= MAXRUNSPEED and oldSpeedX <= MAXRUNSPEED) or (mario.speedX <= -MAXRUNSPEED and oldSpeedX >= -MAXRUNSPEED)) then
        if mario.speedX > 0 then
            mario.speedX = MAXRUNSPEED
        else
            mario.speedX = -MAXRUNSPEED
        end
    end

    if maxSpeed then
        if acceleration > 0 then
            mario.speedX = math.min(mario.speedX, maxSpeed)
        else
            mario.speedX = math.max(mario.speedX, -maxSpeed)
        end
    end

    -- Kill movement below a threshold
    if math.abs(mario.speedX) < MINSPEED and (not keyDown("right") and not keyDown("left")) then
        mario.speedX = 0
    end
end

function character.animation(dt, mario)
    if mario.onGround and mario.speedX == 0 then
        mario.animationState = "idle"
    end

    if mario.onGround and ((keyDown("left") and mario.speedX > 0) or (keyDown("right") and mario.speedX < 0)) then
        mario.animationState = "sliding"
    elseif mario.onGround and mario.speedX ~= 0 then
        mario.animationState = "running"
    end

    if mario.animationState == "running" and mario.onGround then
        mario.runAnimationTimer = mario.runAnimationTimer + (math.abs(mario.speedX)+4)/5*dt --wtf is this
        while mario.runAnimationTimer > RUNANIMATIONTIME do
            mario.runAnimationTimer = mario.runAnimationTimer - RUNANIMATIONTIME
            mario.runAnimationFrame = mario.runAnimationFrame + 1

            if mario.runAnimationFrame > mario.char.data.runFrames then
                mario.runAnimationFrame = mario.runAnimationFrame - mario.char.data.runFrames
            end
        end
    end

    if keyDown("left") and mario.onGround then
        mario.animationDirection = -1
    elseif keyDown("right") and mario.onGround then
        mario.animationDirection = 1
    end
end

function character.jump(dt, mario)
    -- Adjust jumpforce according to speed
    local jumpforce = JUMPFORCE

    jumpforce = jumpforce + math.max(0, math.min(1, math.abs(mario.speedX)/MAXRUNSPEED)) * JUMPFORCEADD

    mario.speedY = -jumpforce
    mario.animationState = "jumping"
end

return character