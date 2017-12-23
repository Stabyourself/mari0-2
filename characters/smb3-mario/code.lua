local character = {}

local WALKACCELERATION = 128 --acceleration of walking on ground
local RUNACCELERATION = 256 --acceleration of running on ground
local WALKACCELERATIONAIR = 128 --acceleration of walking in the air
local RUNACCLERATIONAIR = 256 --acceleration of running in the air
local MINSPEED = 11.2 --When FRICTION is in effect and speed falls below this, speed is set to 0
local MAXWALKSPEED = 102.4 --fastest speedx when walking
local MAXRUNSPEED = 144 --fastest speedx when running
local FRICTION = 224 --amount of speed that is substracted when not pushing buttons, as well as speed added to acceleration when changing directions
local SUPERFRICTION = 1600 --see above, but when speed is greater than MAXRUNSPEED
local FRICTIONAIR = 0 --see above, but in air
local AIRSLIDEFACTOR = 0.8 --multiply of acceleration in air when changing direction

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

        if keyDown("left") then
            acceleration = acceleration - accelerationVal

            if not mario.onGround and mario.speedX > 0 then
                acceleration = acceleration * AIRSLIDEFACTOR
            end
        end

        if keyDown("right") then
            acceleration = acceleration + accelerationVal

            if not mario.onGround and mario.speedX < 0 then
                acceleration = acceleration * AIRSLIDEFACTOR
            end
        end
    end

    -- Apply friction?
    if  (not keyDown("right") and not keyDown("left")) or 
        (mario.ducking and mario.onGround) or
        mario.disabled or
        (not keyDown("run") and math.abs(mario.speedX) > MAXWALKSPEED) or
        math.abs(mario.speedX) > MAXRUNSPEED or
        ((acceleration < 0 and mario.speedX > 0) or (acceleration > 0 and mario.speedX < 0)) then

        -- Friction multiplier
        local friction = FRICTION
        if not mario.onGround then
            friction = FRICTIONAIR
        elseif math.abs(mario.speedX) > MAXRUNSPEED then
            friction = SUPERFRICTION
        end

        if mario.speedX > 0 then
            acceleration = acceleration - FRICTION
        elseif mario.speedX < 0 then
            acceleration = acceleration + FRICTION
        end
    end

    -- Clamp max speeds for walk and run
    local maxSpeed

    if (not keyDown("run") and math.abs(mario.speedX) < MAXWALKSPEED) then
        maxSpeed = MAXWALKSPEED
    elseif (keyDown("run") and math.abs(mario.speedX) < MAXRUNSPEED) then
        maxSpeed = MAXRUNSPEED
    end

    mario.speedX = mario.speedX + acceleration*dt

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