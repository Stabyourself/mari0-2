local Character = class("SMB3Mario", Mario)

local ACCELERATION = 196.875 -- acceleration on ground

local NORMALGRAVITY = 1125
local JUMPGRAVITY = 225
local JUMPGRAVITYUNTIL = -120
local BUTTACCELERATION = 225 -- this is per 1/8*pi of downhill slope

local MAXSPEEDS = {90, 150, 210}
local MAXSPEEDFLY = 86.25

local FRICTION = 140.625 -- amount of speed that is substracted when not pushing buttons
local FRICTIONICE = 42.1875 -- duh
local FRICTIONBUTT = 277+7/9
local FRICTIONFLYSMALL = 56.25
local FRICTIONFLYBIG = 225

local FRICTIONSKID = 450 -- turnaround speed
local FRICTIONSKIDFLY = 675 -- turnaround speed while flying
local FRICTIONSKIDICE = 182.8125 -- turnaround speed on ice

local RUNANIMATIONTIME = 1.2

local JUMPFORCE = 256
local JUMPFORCEADD = 30.4 -- how much jumpforce is added at top speed (linear from 0 to topspeed)

local PMETERTIMEUP = 8/60
local PMETERTIMEDOWN = 24/60
local PMETERTIMEMARGIN = 16/60

local DOWNHILLWALKBONUS = 7.5

local FLYTIME = 4.25
local FLYINGASCENSION = -90
local FLOATASCENSION = 60

local FLYINGUPTIME = 16/60
local FLOATTIME = 16/60

local JUMPTABLE = {
    {speedX = 60, speedY = -206.25},
    {speedX = 120, speedY = -213.75},
    {speedX = 180, speedY = -221.25},
    {speedX = math.huge, speedY = -236.25},
}

local powerUpStates = {
    small = {
        width = 20,
        height = 20,
        centerX = 10,
        centerY = 11,
        frames = {
            "idle",
            "run",
            "run",
            "sprint",
            "sprint",
            "skid",
            "jump",
            "jumpWithPassion",
            "die",
            "buttSlide",
            "swim",
            "swim",
            "swim",
            "swim",
            "pipe",
            "hold",
            "holdIdle",
            "holdRun",
            "holdRun",
            "climb",
            "climb",
        },
    },
    
    big = {
        width = 40,
        height = 40,
        centerX = 23,
        centerY = 24,
        frames = {
            "idle",
            "run",
            "run",
            "run",
            "sprint",
            "sprint",
            "sprint",
            "skid",
            "jump",
            "jumpWithPassion",
            "die",
            "buttSlide",
            "swim",
            "swim",
            "swim",
            "swim",
            "pipe",
            "hold",
            "holdIdle",
            "holdRun",
            "holdRun",
            "holdRun",
            "climb",
            "climb",
        },
    },
    
    raccoon = {
        width = 40,
        height = 40,
        centerX = 23,
        centerY = 24,
        frames = {
            "idle",
            "run",
            "run",
            "run",
            "sprint",
            "sprint",
            "sprint",
            "skid",
            "jump",
            "jumpWithPassion",
            "die",
            "buttSlide",
            "swim",
            "swim",
            "swim",
            "swim",
            "pipe",
            "hold",
            "holdIdle",
            "holdRun",
            "holdRun",
            "holdRun",
            "climb",
            "climb",
        },
    }
}

for i, v in pairs(powerUpStates) do
    Character[i] = {}
    local char = Character[i]
    
    char.centerX = v.centerX
    char.centerY = v.centerY
    
    char.img = love.graphics.newImage("characters/smb3-mario/" .. i .. ".png")
    char.quad = {}
    
    for y = 1, 5 do
        char.quad[y] = {}
        local x = 0
        
        for _, name in ipairs(v.frames) do
            local quad = love.graphics.newQuad(x*v.width, (y-1)*v.height, v.width, v.height, Character[i].img:getWidth(), Character[i].img:getHeight())
            
            if char.quad[y][name] then
                if type(char.quad[y][name]) ~= "table" then
                    char.quad[y][name] = {char.quad[y][name]}
                end
                
                table.insert(char.quad[y][name], quad)
            else
                char.quad[y][name] = quad
            end
                
            x = x + 1
        end
    end
end

local state = {}


state.idle = CharacterState:new("idle", function(self)
    if keyDown("right") or keyDown("left") then
        return "run"
    end
end)


state.run = CharacterState:new("run", function(self)
    if not keyDown("right") and not keyDown("left") then
        return "idle"
    end
    
    if  self.groundSpeedX > 0 and keyDown("left") or
        self.groundSpeedX < 0 and keyDown("right") then
        return "skid"
    end
end)


state.skid = CharacterState:new("skid", function(self)
    if  self.groundSpeedX == 0 or 
        (self.groundSpeedX < 0 and keyDown("left") and not keyDown("right")) or
        (self.groundSpeedX > 0 and keyDown("right") and not keyDown("right")) or
        (self.groundSpeedX > 0 and not keyDown("left")) or
        (self.groundSpeedX < 0 and not keyDown("right")) then
        return "run"
    end
end)


state.jump = CharacterState:new("jump", function(self)
    -- handled by bottomCollision
end)


state.buttSlide = CharacterState:new("buttSlide", function(self)
    if keyDown("right") or keyDown("left") or (self.groundSpeedX == 0 and self.surfaceAngle == 0) then
        return "idle"
    end
end)

state.raccoonJump = CharacterState:new("raccoonJump", function(self)
    -- handled by bottomCollision and jump
end)

state.fly = CharacterState:new("fly", function(self)
    if not self.flying then
        return "raccoonJump"
    end
    
    if self.flyingUpTimer >= FLYINGUPTIME then
        return "raccoonJump"
    end
end)

state.float = CharacterState:new("float", function(self)
    if self.floatTimer >= FLOATTIME then
        return "raccoonJump"
    end
end)


function Character:initialize(...)
    Mario.initialize(self, ...)
    
    self.flyingUpTimer = FLYINGUPTIME
    self.flyTimer = FLYTIME
    self.flying = false
    
    self.floatTimer = FLOATTIME
    self.img = Character[self.powerUpState].img
    self.quad = Character[self.powerUpState].quad[3][self.animationState]
    
    self.centerX = Character[self.powerUpState].centerX
    self.centerY = Character[self.powerUpState].centerY
    
    self.state = state.idle
end

function Character:switchState(stateName)
    if stateName then
        if stateName ~= true then
            self.state = state[stateName]
        end
        
        self:switchState(self.state:checkExit(self)) -- oh god recursion
    end
end

function Character:movement(dt)
    if self.flyingUpTimer < FLYINGUPTIME then
        self.flyingUpTimer = self.flyingUpTimer + dt
    end
    
    if self.flying then
        self.flyTimer = self.flyTimer + dt
        
        if self.flyTimer >= FLYTIME then
            self.flyTimer = FLYTIME
            self.flying = false
            self.pMeter = 0
        end
    end
    
    if self.floatTimer < FLOATTIME then
        self.floatTimer = self.floatTimer + dt
    end
    
    self:switchState(true)
    
    if self.state == state.idle then
        self:friction(dt)
    end
    
    if self.state == state.run then
        local maxSpeed = 0
        
        if keyDown("left") or keyDown("right") then
            maxSpeed = MAXSPEEDS[1]
        end
        
        if keyDown("run") then
            maxSpeed = MAXSPEEDS[2]
        end
        
        if self.pMeter == VAR("pMeterTicks") and keyDown("run") then
            maxSpeed = MAXSPEEDS[3]
        end
        
        if not self.onGround then
            maxSpeed = self.maxSpeedJump or MAXSPEEDS[1]
        end
    
        -- Normal left/right acceleration
        self:accelerate(dt, maxSpeed)
        
        if math.abs(self.groundSpeedX) > maxSpeed then
            self:friction(dt)
        end
    end
    
    if self.state == state.skid then
        self:skid(dt)
    end
    
    if self.state == state.jump then
        self:accelerate(dt, self.maxSpeedJump)
        self:skid(dt)
    end
    
    if self.state == state.buttSlide then
        local buttAcceleration = BUTTACCELERATION * (self.surfaceAngle/(math.pi/8))
        
        self.groundSpeedX = self.groundSpeedX + buttAcceleration*dt
        
        if self.surfaceAngle == 0 then
            self:friction(dt, FRICTIONBUTT)
        end
    end
    
    if self.state == state.raccoonJump or self.state == state.fly or self.state == state.float then
        if math.abs(self.groundSpeedX) > MAXSPEEDFLY then
            if  self.groundSpeedX > 0 and keyDown("right") or
                self.groundSpeedX < 0 and keyDown("left") then
                self:friction(dt, FRICTIONFLYSMALL, MAXSPEEDFLY)
            else
                self:friction(dt, FRICTIONFLYBIG, MAXSPEEDFLY)
            end
        end
        
        if self.flying or self.state == state.float then
            self:accelerate(dt, MAXSPEEDFLY)
        else
            local maxSpeed = math.min(MAXSPEEDS[2], self.maxSpeedJump)
            
            self:accelerate(dt, maxSpeed)
        end
        
        self:skid(dt, FRICTIONSKIDFLY)
    end
    
    if self.state == state.fly then
        self.speedY = FLYINGASCENSION
    end
    
    if self.state == state.float then
        self.speedY = FLOATASCENSION
    end 
    
    -- P meter
    self.pMeterTimer = self.pMeterTimer + dt
    
    if self.groundSpeedX == MAXSPEEDS[2] and self.pMeter == 0 then
        self.pMeterTime = PMETERTIMEUP
        self.pMeterTimer = PMETERTIMEUP
    end
    
    -- Maintain fullspeed when pMeter full
    if self.pMeter == VAR("pMeterTicks") and
        (not self.onGround or 
        (math.abs(self.groundSpeedX) >= MAXSPEEDS[2] and
        keyDown("run") and 
        ((self.groundSpeedX > 0 and keyDown("right")) or (self.groundSpeedX < 0 and keyDown("left"))))) then
        self.pMeterTimer = 0
        self.pMeterTime = PMETERTIMEMARGIN
    end
    
    if self.flying then -- stuck pMeter to full
        
    else
        while self.pMeterTimer >= self.pMeterTime do
            self.pMeterTimer = self.pMeterTimer - self.pMeterTime
            
            if self.onGround and math.abs(self.speedX) >= MAXSPEEDS[2] then
                if self.pMeter < VAR("pMeterTicks") then
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
    end
    
    self.speedX = self.groundSpeedX
    
    -- Adjust speedx if going downhill or uphill
    if self.onGround then
        if self.surfaceAngle > 0 then
            if self.groundSpeedX > 0 then
                self.speedX = self.speedX + DOWNHILLWALKBONUS
            else
                self.speedX = self.speedX * math.cos(self.surfaceAngle)
            end
        elseif self.surfaceAngle < 0 then
            if self.groundSpeedX < 0 then
                self.speedX = self.speedX - DOWNHILLWALKBONUS
            else
                self.speedX = self.speedX * math.cos(-self.surfaceAngle)
            end
        end
    end

    
    -- Update gravity
    self.gravity = NORMALGRAVITY
    if self.state == state.fly or self.state == state.float then
        self.gravity = 0
    elseif self.jumping and self.speedY < JUMPGRAVITYUNTIL then
        self.gravity = JUMPGRAVITY
    end
end

function Character:friction(dt, friction, min)
    if not friction then
        if somethingIce then -- todo
            friction = FRICTIONICE
        else
            friction = FRICTION
        end
    end
        
    if self.groundSpeedX > (min or 0) then
        self.groundSpeedX = math.max(min or 0, self.groundSpeedX - friction*dt)
    elseif self.groundSpeedX < -(min or 0) then
        self.groundSpeedX = math.min(-(min or 0), self.groundSpeedX + friction*dt)
    end
end

function Character:skid(dt)
    if keyDown("right") and self.groundSpeedX < 0 then
        self.groundSpeedX = math.min(0, self.groundSpeedX + FRICTIONSKID*dt)
    end
    
    if keyDown("left") and self.groundSpeedX > 0 then
        self.groundSpeedX = math.max(0, self.groundSpeedX - FRICTIONSKID*dt)
    end
end

function Character:accelerate(dt, maxSpeed)
    if math.abs(self.groundSpeedX) < maxSpeed then
        if keyDown("left") and not keyDown("right") and self.groundSpeedX <= 0 then
            self.groundSpeedX = math.max(-maxSpeed, self.groundSpeedX - ACCELERATION*dt)
        end

        if keyDown("right") and not keyDown("left") and self.groundSpeedX >= 0 then
            self.groundSpeedX = math.min(maxSpeed, self.groundSpeedX + ACCELERATION*dt)
        end
    end
end

function Character:animation(dt)
    if self.onGround and self.speedX == 0 then
        self.animationState = "idle"
    end

    if self.onGround and ((keyDown("left") and self.speedX > 0) or (keyDown("right") and self.speedX < 0)) then
        self.animationState = "skid"
    elseif self.onGround and self.speedX ~= 0 then
        if math.abs(self.speedX) >= MAXSPEEDS[3] then
            self.animationState = "sprint"
        else
            self.animationState = "run"
        end
    end

    if (self.animationState == "run" or self.animationState == "sprint") and self.onGround then
        self.runAnimationTimer = self.runAnimationTimer + (math.abs(self.speedX)+5)/6*dt
        while self.runAnimationTimer > RUNANIMATIONTIME do
            self.runAnimationTimer = self.runAnimationTimer - RUNANIMATIONTIME
            self.runAnimationFrame = self.runAnimationFrame + 1

            if self.runAnimationFrame > #Character[self.powerUpState].quad[1].run then
                self.runAnimationFrame = self.runAnimationFrame - #Character[self.powerUpState].quad[1].run
            end
        end
    end
    
    if not self.onGround then
        if self.maxSpeedJump == MAXSPEEDS[3] or self.flying then
            self.animationState = "jumpWithPassion"
        else
            self.animationState = "jump"
        end
    end
    
    if self.state == state.buttSlide then
        self.animationState = "buttSlide"
    end

    if self.hasPortalGun then -- look towards portalGunAngle
        if math.abs(self.portalGunAngle) <= math.pi*.5 then
            self.animationDirection = 1
        else
            self.animationDirection = -1
        end
        
    else -- look towards last pressed direction
        if keyDown("left") then
            self.animationDirection = -1
        elseif keyDown("right") then
            self.animationDirection = 1
        end
    end
    
    if (self.animationState == "run" or self.animationState == "sprint") then
        self.quad = Character[self.powerUpState].quad[self:getAngleFrame(self.portalGunAngle)][self.animationState][self.runAnimationFrame]
    else
        self.quad = Character[self.powerUpState].quad[self:getAngleFrame(self.portalGunAngle)][self.animationState]
    end
end

function Character:duck()
    if Mario.duck(self) then
        if self.state ~= state.buttSlide and self.surfaceAngle ~= 0 and self.onGround and not keyDown("left") and not keyDown("right") then
            self:switchState("buttSlide")
            
            if self.surfaceAngle > 0 then
                self.groundSpeedX = math.max(0, self.groundSpeedX)
            else
                self.groundSpeedX = math.min(0, self.groundSpeedX)
            end
        end
    end
end

function Character:jump()
    if (self.state == state.raccoonJump or self.state == state.fly) and self.flying then
        self.flyingUpTimer = 0
        self:switchState("fly")
    end
    
    if self.state == state.raccoonJump or self.state == state.float then
        self.floatTimer = 0
        self:switchState("float")
    end
    
    if Mario.jump(self) then
        -- See if Mario should switch to flying mode
        if self.canFly then
            self:switchState("raccoonJump")
            
            if self.pMeter == VAR("pMeterTicks") and not self.flying then
                self.flyTimer = 0
                self.flying = true
            end
        else
            self:switchState("jump")
        end
        
        -- Adjust jumpforce according to speed
        local speedY = 0
        for i = 1, #JUMPTABLE do
            if math.abs(self.groundSpeedX) <= JUMPTABLE[i].speedX then
                speedY = JUMPTABLE[i].speedY
                break
            end
        end
        
        -- Store how fast Mario is allowed to accelerate during the jump
        local maxSpeedJump
        
        for i = 1, #MAXSPEEDS do
            if math.abs(self.groundSpeedX) <= MAXSPEEDS[i] then
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
end

function Character:bottomCollision(obj2)
    Mario.bottomCollision(self, obj2)
    
    if self.state == state.jump or self.state == state.raccoonJump then
        self:switchState("idle")
    end
end

return Character