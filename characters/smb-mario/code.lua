local Character = class("SMBMario", Mario)

local WALKACCELERATION = 128 --acceleration of walking on ground
local RUNACCELERATION = 256 --acceleration of running on ground
local WALKACCELERATIONAIR = 128 --acceleration of walking in the air
local RUNACCLERATIONAIR = 256 --acceleration of running in the air
local MINSPEED = 11.2 --When FRICTION is in effect and speed falls below this, speed is set to 0
local MAXWALKSPEED = 102.4 --fastest speed.x when walking
local MAXRUNSPEED = 144 --fastest speed.x when running
local FRICTION = 224 --amount of speed that is substracted when not pushing buttons, as well as speed added to acceleration when changing directions
local SUPERFRICTION = 1600 --see above, but when speed is greater than MAXRUNSPEED
local FRICTIONAIR = 0 --see above, but in air
local AIRSLIDEFACTOR = 0.8 --multiply of acceleration in air when changing direction

local RUNANIMATIONTIME = 1.6 --

local JUMPFORCE = 256
local JUMPFORCEADD = 30.4 --how much jumpforce is added at top speed (linear from 0 to topspeed)

Character.img = love.graphics.newImage("characters/smb-mario/graphics.png")

Character.quads = {}
Character.quads.idle = {}
Character.quads.running = {}
Character.quads.sprinting = {}
Character.quads.sliding = {}
Character.quads.jumping = {}
Character.quads.jumpingWithPassion = {}
Character.quads.buttSliding = {}

for y = 1, 5 do
    Character.quads.idle[y] = love.graphics.newQuad(0, (y-1)*20, 20, 20, Character.img:getDimensions())

    Character.quads.running[y] = {}
    for i = 1, 3 do
        Character.quads.running[y][i] = love.graphics.newQuad(i*20, (y-1)*20, 20, 20, Character.img:getDimensions())
    end

    
    Character.quads.sliding[y] = love.graphics.newQuad(80, (y-1)*20, 20, 20, Character.img:getDimensions())
    Character.quads.jumping[y] = love.graphics.newQuad(100, (y-1)*20, 20, 20, Character.img:getDimensions())
end

function Character:initialize(...)
    Mario.initialize(self, ...)
    
    self.centerX = 10
    self.centerY = 10
    self.runAnimationTimer = 0
    self.runAnimationFrame = 1
    self.quad = Character.quads.idle[3]
end

function Character:movement(dt)
    --Todo: Don't accelerate past maxwalkspeed in air!
    --Todo: Some stuff about automatically getting maxrunspeed if on maxwalkspeed when landing
    local acceleration = 0

    -- Normal left/right acceleration
    if (not keyDown("run") and math.abs(self.speed.x) <= MAXWALKSPEED) or (keyDown("run") and math.abs(self.speed.x) <= MAXRUNSPEED) then
        local accelerationVal = WALKACCELERATION
        if keyDown("run") then
            accelerationVal = RUNACCELERATION
        end

        if keyDown("left") then
            acceleration = acceleration - accelerationVal

            if not self.onGround and self.speed.x > 0 then
                acceleration = acceleration * AIRSLIDEFACTOR
            end
        end

        if keyDown("right") then
            acceleration = acceleration + accelerationVal

            if not self.onGround and self.speed.x < 0 then
                acceleration = acceleration * AIRSLIDEFACTOR
            end
        end
    end

    -- Apply friction?
    if  (not keyDown("right") and not keyDown("left")) or 
        (self.ducking and self.onGround) or
        self.disabled or
        (not keyDown("run") and math.abs(self.speed.x) > MAXWALKSPEED) or
        math.abs(self.speed.x) > MAXRUNSPEED or
        ((acceleration < 0 and self.speed.x > 0) or (acceleration > 0 and self.speed.x < 0)) then

        -- Friction multiplier
        local friction = FRICTION
        if not self.onGround then
            friction = FRICTIONAIR
        elseif math.abs(self.speed.x) > MAXRUNSPEED then
            friction = SUPERFRICTION
        end

        if self.speed.x > 0 then
            acceleration = acceleration - FRICTION
        elseif self.speed.x < 0 then
            acceleration = acceleration + FRICTION
        end
    end

    -- Clamp max speeds for walk and run
    local maxSpeed

    if (not keyDown("run") and math.abs(self.speed.x) < MAXWALKSPEED) then
        maxSpeed = MAXWALKSPEED
    elseif (keyDown("run") and math.abs(self.speed.x) < MAXRUNSPEED) then
        maxSpeed = MAXRUNSPEED
    end

    self.speed.x = self.speed.x + acceleration*dt

    if maxSpeed then
        if acceleration > 0 then
            self.speed.x = math.min(self.speed.x, maxSpeed)
        else
            self.speed.x = math.max(self.speed.x, -maxSpeed)
        end
    end

    -- Kill movement below a threshold
    if math.abs(self.speed.x) < MINSPEED and (not keyDown("right") and not keyDown("left")) then
        self.speed.x = 0
    end
end

function Character:animation(dt)
    if self.onGround and self.speed.x == 0 then
        self.animationState = "idle"
    end

    if self.onGround and ((keyDown("left") and self.speed.x > 0) or (keyDown("right") and self.speed.x < 0)) then
        self.animationState = "sliding"
    elseif self.onGround and self.speed.x ~= 0 then
        self.animationState = "running"
    end

    if self.animationState == "running" and self.onGround then
        self.runAnimationTimer = self.runAnimationTimer + (math.abs(self.speed.x)+4)/5*dt --wtf is this
        while self.runAnimationTimer > RUNANIMATIONTIME do
            self.runAnimationTimer = self.runAnimationTimer - RUNANIMATIONTIME
            self.runAnimationFrame = self.runAnimationFrame + 1

            if self.runAnimationFrame > 3 then
                self.runAnimationFrame = self.runAnimationFrame - 3
            end
        end
    end

    if keyDown("left") and self.onGround then
        self.animationDirection = -1
    elseif keyDown("right") and self.onGround then
        self.animationDirection = 1
    end

    if (self.animationState == "running" or self.animationState == "sprinting") then
        self.quad = self.quads[self.animationState][3][self.runAnimationFrame]
    else
        self.quad = self.quads[self.animationState][3]
    end
end

function Character:jump()
    -- Adjust jumpforce according to speed
    local jumpforce = JUMPFORCE

    jumpforce = jumpforce + math.max(0, math.min(1, math.abs(self.speed.x)/MAXRUNSPEED)) * JUMPFORCEADD

    self.speed.y = -jumpforce
    self.animationState = "jumping"
    self.onGround = false
end

return Character