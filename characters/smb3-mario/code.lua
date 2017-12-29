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

local FLYANIMATIONTIME = 4/60
local FLOATANIMATIONTIME = 4/60

local SPINTIME = 19/60
local SPINFRAMETIME = 4/60

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
            "fly",
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
        canDuck = true,
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
            "fly",
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
        canSpin = true,
        canFly = true,
        canFloat = true,
        canDuck = true,
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
            
            "fall",
            
            "fly",
            "fly",
            "fly",
            
            "float",
            "float",
            "float",
            
            "die",
            
            "duck",
            
            "buttSlide",
            
            "swim",
            "swim",
            "swim",
            "swim",
            
            "spin",
            "spin",
            "spin",
            "spin",
            
            "spinAir",
            "spinAir",
            "spinAir",
            "spinAir",
            
            "holdIdle",
            
            "holdRun",
            "holdRun",
            "holdRun",
            
            "kick",
            
            "climb",
            "climb",
            
            "summerSault",
            "summerSault",
            "summerSault",
            "summerSault",
            "summerSault",
            "summerSault",
            "summerSault",
            "summerSault",
        },
    }
}

for i, v in pairs(powerUpStates) do
    Character[i] = {}
    local char = Character[i]
    
    char.centerX = v.centerX
    char.centerY = v.centerY
    char.canFly = v.canFly
    char.canFloat = v.canFloat
    char.canSpin = v.canSpin
    char.canDuck = v.canDuck
    
    
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


state.idle = function(mario)
    if keyDown("right") or keyDown("left") then
        return "run"
    end
    
    if mario.groundSpeedX ~= 0 then
        return "stop"
    end
end


state.stop = function(mario)
    if keyDown("right") or keyDown("left") then
        return "run"
    end
    
    if mario.groundSpeedX == 0 then
        return "idle"
    end
end


state.run = function(mario)
    if not keyDown("right") and not keyDown("left") then
        return "stop"
    end
    
    if  mario.groundSpeedX > 0 and keyDown("left") or
        mario.groundSpeedX < 0 and keyDown("right") then
        return "skid"
    end
end


state.skid = function(mario)
    if mario.groundSpeedX == 0 then
        return "idle"
    end
    
    if  (mario.groundSpeedX < 0 and keyDown("left") and not keyDown("right")) or
        (mario.groundSpeedX > 0 and keyDown("right") and not keyDown("right")) or
        (mario.groundSpeedX > 0 and not keyDown("left")) or
        (mario.groundSpeedX < 0 and not keyDown("right")) then
        return "run"
    end
end


state.jump = function(mario)
    if not keyDown("jump") or mario.speedY >= JUMPGRAVITYUNTIL then
        return "fall"
    end
end

state.fall = function(mario)
    if keyDown("jump") and mario.speedY < JUMPGRAVITYUNTIL then
        return "jump"
    end
    -- handled by bottomCollision
end


state.buttSlide = function(mario)
    if keyDown("right") or keyDown("left") or (mario.groundSpeedX == 0 and mario.surfaceAngle == 0) then
        return "idle"
    end
end


state.fly = function(mario, characterState)
    if not mario.flying then
        return "fall"
    end
    
    if characterState.timer >= FLYINGUPTIME then
        return "fall"
    end
end


state.float = function(mario, characterState)
    if characterState.timer >= FLOATTIME then
        return "fall"
    end
end


function Character:initialize(...)
    Mario.initialize(self, ...)
    
    self.flyTimer = FLYTIME
    self.flying = false
    
    self.img = Character[self.powerUpState].img
    self.quad = Character[self.powerUpState].quad[3][self.animationState]
    
    self.centerX = Character[self.powerUpState].centerX
    self.centerY = Character[self.powerUpState].centerY
    
    self.state = CharacterState:new("idle", state.idle)
    
    self.runAnimationFrame = 1
    self.runAnimationTimer = 0
    
    self.flyAnimationFrame = 1
    self.flyAnimationTimer = 0
    
    self.floatAnimationFrame = 1
    self.floatAnimationFrame = 0
    
    self.spinning = false
    self.spinTimer = SPINTIME
end

function Character:switchState(stateName)
    if stateName then
        if stateName ~= true then
            assert(state[stateName], "Tried to switch to nonexistent CharacterState \"" .. stateName .. "\" and that's bad.")
            self.state = CharacterState:new(stateName, state[stateName])
        end
        
        self:switchState(self.state:checkExit(self)) -- oh god recursion
    end
end

function Character:movement(dt)
    if self.flying then
        self.flyTimer = self.flyTimer + dt
        
        if self.flyTimer >= FLYTIME then
            self.flyTimer = FLYTIME
            self.flying = false
            self.pMeter = 0
        end
    end
    
    if self.spinning then
        self.spinTimer = self.spinTimer + dt
        
        if self.spinTimer >= SPINTIME then
            self.spinTimer = SPINTIME
            self.spinning = false
        end
    end
    
    self.state:update(dt)
    self:switchState(true)
    
    if self.state.name == "idle" then
        
    end
    
    if self.state.name == "stop" then
        self:friction(dt)
    end
    
    if self.state.name == "run" then
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
    
    if self.state.name == "skid" then
        self:skid(dt)
    end
    
    if not self.flying and (self.state.name == "jump" or self.state.name == "fall") then
        self:accelerate(dt, self.maxSpeedJump or MAXSPEEDS[1])
        self:skid(dt)
    end
    
    if self.state.name == "buttSlide" then
        local buttAcceleration = BUTTACCELERATION * (self.surfaceAngle/(math.pi/8))
        
        self.groundSpeedX = self.groundSpeedX + buttAcceleration*dt
        
        if self.surfaceAngle == 0 then
            self:friction(dt, FRICTIONBUTT)
        end
    end
    
    if (self.flying and (self.state.name == "jump" or self.state.name == "fall")) or self.state.name == "fly" or self.state.name == "float" then
        if math.abs(self.groundSpeedX) > MAXSPEEDFLY then
            if  self.groundSpeedX > 0 and keyDown("right") or
                self.groundSpeedX < 0 and keyDown("left") then
                self:friction(dt, FRICTIONFLYSMALL, MAXSPEEDFLY)
            else
                self:friction(dt, FRICTIONFLYBIG, MAXSPEEDFLY)
            end
        end
        
        if self.flying or self.state.name == "float" then
            self:accelerate(dt, MAXSPEEDFLY)
        else
            local maxSpeed = math.min(MAXSPEEDS[2], self.maxSpeedJump)
            
            self:accelerate(dt, maxSpeed)
        end
        
        self:skid(dt, FRICTIONSKIDFLY)
    end
    
    if self.state.name == "fly" then
        self.speedY = FLYINGASCENSION
    end
    
    if self.state.name == "float" then
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
    
    -- Ducking
    if self.onGround then
        if keyDown("down") and not keyDown("left") and not keyDown("right") and self.state.name ~= "buttSlide" then
            if self.surfaceAngle ~= 0 then -- check if buttslide
                self:switchState("buttSlide")
                
                if self.surfaceAngle > 0 then
                    self.groundSpeedX = math.max(0, self.groundSpeedX)
                else
                    self.groundSpeedX = math.min(0, self.groundSpeedX)
                end
            elseif Character[self.powerUpState].canDuck then
                self.ducking = true
                
                -- Stop spinning if was spinning
                if Character[self.powerUpState].canSpin then
                    self.spinning = false
                    self.spinTimer = SPINTIME
                end
            end
        else
            self.ducking = false
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
    if self.state.name == "fly"or self.state.name == "float" then
        self.gravity = 0
    elseif self.state.name == "jump" then
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
    
    local frame = false
    
    if self.spinning then
        if self.onGround then
            self.animationState = "spin"
        else
            self.animationState = "spinAir"
        end
        
        self.animationDirection = self.spinDirection
        
        -- calculate spin frame from spinTimer
        local spinFrames = #Character[self.powerUpState].quad[1].spin
        
        local time = math.fmod(self.spinTimer, spinFrames*SPINFRAMETIME)
        
        frame = math.ceil(time/SPINFRAMETIME)
        
    elseif self.ducking then
        self.animationState = "duck"
        
    elseif self.state.name == "idle" then
        self.animationState = "idle"
        
    elseif self.state.name == "skid" then
        self.animationState = "skid"
        
    elseif self.state.name == "stop" or self.state.name == "run" then
        if math.abs(self.speedX) >= MAXSPEEDS[3] then
            self.animationState = "sprint"
        else
            self.animationState = "run"
        end
        
    elseif self.flying and (self.state.name == "jump" or self.state.name == "fly" or self.state.name == "fall") then
        self.animationState = "fly"
        
    elseif self.state.name == "float" then
        self.animationState = "float"
        
    elseif self.state.name == "jump" or self.state.name == "fall" then
        if self.speedY < 0 then
            if self.maxSpeedJump == MAXSPEEDS[3] or self.flying then
                self.animationState = "fly"
            else
                self.animationState = "jump"
            end
        else   
            self.animationState = "fall"
        end
        
    elseif self.state.name == "buttSlide" then
        self.animationState = "buttSlide"
    end

    
    -- Running animation
    if (self.animationState == "run" or self.animationState == "sprint") then
        self.runAnimationTimer = self.runAnimationTimer + (math.abs(self.speedX)+50)/8*dt
        while self.runAnimationTimer > RUNANIMATIONTIME do
            self.runAnimationTimer = self.runAnimationTimer - RUNANIMATIONTIME
            self.runAnimationFrame = self.runAnimationFrame + 1
            
            local runFrames = #Character[self.powerUpState].quad[1].run

            if self.runAnimationFrame > runFrames then
                self.runAnimationFrame = self.runAnimationFrame - runFrames
            end
        end
        
        frame = self.runAnimationFrame
    end
    
    -- Flying animation
    if self.animationState == "fly" then
        if self.state.name == "fall" then
            self.flyAnimationFrame = 2
        else
            self.flyAnimationTimer = self.flyAnimationTimer + dt
            while self.flyAnimationTimer > FLYANIMATIONTIME do
                self.flyAnimationTimer = self.flyAnimationTimer - FLYANIMATIONTIME
                self.flyAnimationFrame = self.flyAnimationFrame + 1

                local flyFrames = #Character[self.powerUpState].quad[1].fly
                if self.flyAnimationFrame > flyFrames then
                    self.flyAnimationFrame = flyFrames -- don't reset to the start
                end
            end
        end
        
        frame = self.flyAnimationFrame
    end
    
    -- Float animation
    if self.animationState == "float" then
        self.floatAnimationTimer = self.floatAnimationTimer + dt
        while self.floatAnimationTimer > FLYANIMATIONTIME do
            self.floatAnimationTimer = self.floatAnimationTimer - FLYANIMATIONTIME
            self.floatAnimationFrame = self.floatAnimationFrame + 1

            local floatFrames = #Character[self.powerUpState].quad[1].float
            if self.floatAnimationFrame > floatFrames then
                self.floatAnimationFrame = floatFrames -- don't reset to the start
            end
        end
        
        frame = self.floatAnimationFrame
    end
    
    -- Make sure to properly use the tables if it's an animationState with frames
    if frame then
        self.quad = Character[self.powerUpState].quad[self:getAngleFrame(self.portalGunAngle)][self.animationState][frame]
    else
        self.quad = Character[self.powerUpState].quad[self:getAngleFrame(self.portalGunAngle)][self.animationState]
    end
    
    assert(type(self.quad) == "userdata", "The state \"" .. self.animationState .. "\" seems to not be have a quad set up correctly.")
end

function Character:jump()
    if Character[self.powerUpState].canFly and self.flying and (self.state.name == "jump" or self.state.name == "fly" or self.state.name == "fall") then
        self:switchState("fly")
        self.flyAnimationTimer = 0
        self.flyAnimationFrame = 1
    end
    
    if Character[self.powerUpState].canFloat and self.speedY > 0 and (self.state.name == "jump" or self.state.name == "float" or self.state.name == "fall") then
        self:switchState("float")
        self.floatAnimationTimer = 0
        self.floatAnimationFrame = 1
    end
    
    if Mario.jump(self) then
        -- Adjust jumpforce according to speed
        local speedY = 0
        for i = 1, #JUMPTABLE do
            if math.abs(self.groundSpeedX) <= JUMPTABLE[i].speedX then
                speedY = JUMPTABLE[i].speedY
                break
            end
        end
        
        -- Store how fast Mario is allowed to accelerate during the jump
        local maxSpeedJumps
        
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
        
        -- See if Mario should switch to flying mode
        if Character[self.powerUpState].canFly then
            self:switchState("jump")
            
            if self.pMeter == VAR("pMeterTicks") and not self.flying then
                self.flyTimer = 0
                self.flying = true
            end
        else
            self:switchState("jump")
        end
        
    end
end

function Character:bottomCollision(obj2)
    Mario.bottomCollision(self, obj2)
    
    if self.state.name == "jump" or self.state.name == "fall" or self.state.name == "float" then
        self:switchState("idle")
    end
end

function Character:startFall()
    self:switchState("fall")
end

function Character:spin() -- that's a good trick
    if Character[self.powerUpState].canSpin and not self.spinning and not keyDown("down") then
        self.spinning = true
        self.spinTimer = 0
        self.spinDirection = self.animationDirection
    end
end

return Character