local character = {}

local ACCELERATION = 196.875 --acceleration

local MAXSPEEDS = {90, 150, 210}

local FRICTION = 140.625 --amount of speed that is substracted when not pushing buttons
local FRICTIONICE = 42.1875 --duh

local FRICTIONSKID = 450 --turnaround speed
local FRICTIONSKIDICE = 182.8125 --turnaround speed on ice

local RUNANIMATIONTIME = 1.2

local JUMPFORCE = 256
local JUMPFORCEADD = 30.4 --how much jumpforce is added at top speed (linear from 0 to topspeed)

PMETERTICKS = 7
PMETERTIMEUP = 8/60
PMETERTIMEDOWN = 24/60
PMETERTIMEMARGIN = 16/60

local JUMPTABLE = {
    {speedX = 60, speedY = -206.25},
    {speedX = 120, speedY = -213.75},
    {speedX = 180, speedY = -221.25},
    {speedX = math.huge, speedY = -236.25},
}

character.runFrames = 2

function character.movement(dt, self)
    local maxSpeed = MAXSPEEDS[1]
    
    if keyDown("run") then
        maxSpeed = MAXSPEEDS[2]
    end
    
    if self.pMeter == PMETERTICKS and keyDown("run") then
        maxSpeed = MAXSPEEDS[3]
    end
    
    if not self.onGround then
        maxSpeed = self.maxSpeedJump or MAXSPEEDS[1]
    end

    -- Normal left/right acceleration
    if math.abs(self.speedX) < maxSpeed then
        if keyDown("left") and not keyDown("right") and self.speedX <= 0 then
            self.speedX = math.max(-maxSpeed, self.speedX - ACCELERATION*dt)
        end

        if keyDown("right") and not keyDown("left") and self.speedX >= 0 then
            self.speedX = math.min(maxSpeed, self.speedX + ACCELERATION*dt)
        end
    end

    -- Apply friction?
    if self.onGround then
        if (not keyDown("right") and not keyDown("left")) or 
            self.ducking or
            self.disabled or
            math.abs(self.speedX) > maxSpeed then
                
            if self.speedX > 0 then
                self.speedX = math.max(0, self.speedX - FRICTION*dt)
            elseif self.speedX < 0 then
                self.speedX = math.min(0, self.speedX + FRICTION*dt)
            end
        end
    end
    
    if keyDown("right") and self.speedX < 0 then
        self.speedX = math.min(0, self.speedX + FRICTIONSKID*dt)
    end
    
    if keyDown("left") and self.speedX > 0 then
        self.speedX = math.max(0, self.speedX - FRICTIONSKID*dt)
    end
    
    -- P meter
    self.pMeterTimer = self.pMeterTimer + dt
    
    if self.speedX == MAXSPEEDS[2] and self.pMeter == 0 then
        self.pMeterTime = PMETERTIMEUP
        self.pMeterTimer = PMETERTIMEUP
    end
    
    -- Maintain fullspeed when pMeter full
    if self.pMeter == PMETERTICKS and
        (not self.onGround or 
        (math.abs(self.speedX) >= MAXSPEEDS[2] and
        keyDown("run") and 
        ((self.speedX > 0 and keyDown("right")) or (self.speedX < 0 and keyDown("left"))))) then
        self.pMeterTimer = 0
        self.pMeterTime = PMETERTIMEMARGIN
    end
    
    while self.pMeterTimer >= self.pMeterTime do
        self.pMeterTimer = self.pMeterTimer - self.pMeterTime
        
        if self.onGround and math.abs(self.speedX) >= MAXSPEEDS[2] then
            if self.pMeter < PMETERTICKS then
                self.pMeterTime = PMETERTIMEUP
                self.pMeter = self.pMeter + 1
            end
        else
            if self.pMeter > 0 then
                self.pMeterTime = PMETERTIMEDOWN
                self.pMeter = self.pMeter - 1
                
                if self.pMeter == 0 then
                    self.pMeterTime = PMETERTIMEUP
                end
            end
        end
    end
    
    -- Update gravity
    self.gravity = 1125
    if self.jumping and self.speedY < -120 then
        self.gravity = 225
    end
end

function character.animation(dt, self)
    if self.onGround and self.speedX == 0 then
        self.animationState = "idle"
    end

    if self.onGround and ((keyDown("left") and self.speedX > 0) or (keyDown("right") and self.speedX < 0)) then
        self.animationState = "sliding"
    elseif self.onGround and self.speedX ~= 0 then
        if math.abs(self.speedX) >= MAXSPEEDS[3] then
            self.animationState = "sprinting"
        else
            self.animationState = "running"
        end
    end

    if (self.animationState == "running" or self.animationState == "sprinting") and self.onGround then
        self.runAnimationTimer = self.runAnimationTimer + (math.abs(self.speedX)+5)/6*dt
        while self.runAnimationTimer > RUNANIMATIONTIME do
            self.runAnimationTimer = self.runAnimationTimer - RUNANIMATIONTIME
            self.runAnimationFrame = self.runAnimationFrame + 1

            if self.runAnimationFrame > self.char.data.runFrames then
                self.runAnimationFrame = self.runAnimationFrame - self.char.data.runFrames
            end
        end
    end
    
    if not self.onGround then
        if self.maxSpeedJump == MAXSPEEDS[3] then
            self.animationState = "jumpingWithPassion"
        else
            self.animationState = "jumping"
        end
    end

    if keyDown("left") then
        self.animationDirection = -1
    elseif keyDown("right") then
        self.animationDirection = 1
    end
end

function character.jump(dt, self)
    -- Adjust jumpforce according to speed
    local speedY = 0
    for i = 1, #JUMPTABLE do
        if math.abs(self.speedX) <= JUMPTABLE[i].speedX then
            speedY = JUMPTABLE[i].speedY
            break
        end
    end
    
    -- Store how fast Mario is allowed to accelerate during the jump
    local maxSpeedJump
    
    for i = 1, #MAXSPEEDS do
        if math.abs(self.speedX) <= MAXSPEEDS[i] then
            maxSpeedJump = MAXSPEEDS[i]
            break
        end
    end
    
    if not maxSpeedJump then
        maxSpeedJump = MAXSPEEDS[#MAXSPEEDS]
    end
    
    self.maxSpeedJump = maxSpeedJump
    
    self.speedY = speedY
end

return character