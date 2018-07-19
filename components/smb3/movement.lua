local Component = require "class.Component"
local ActorState = require "class.ActorState"
local movement = class("smb3.movement", Component)

local ACCELERATION = 196.875 -- acceleration on ground

local JUMPGRAVITYUNTIL = -120

local MAXSPEEDS = {90, 150, 210}

local FRICTION = 140.625 -- amount of speed that is substracted when not pushing buttons
-- local FRICTIONICE = 42.1875 -- duh

local SKIDACCELERATION = 450 -- turnaround speed
-- local SKIDACCELERATIONICE = 182.8125 -- turnaround speed on ice

local PMETERTIMEUP = 8/60
local PMETERTIMEDOWN = 24/60
local PMETERTIMEMARGIN = 16/60

local UW_MAXWALKSPEED = 30
local UW_WALKACCELERATION = 225
local UW_WALKFRICTION = 168.75
local UW_SKIDACCELERATION = 225

local UW_MINSURFACESPEED = -45
local UW_SURFACEJUMPFORCE = -191.25

local UW_GRAVITY = 30 -- applied when moving downwards
local UW_SWIMGRAVITY = 60 -- applied when moving upwards
local UW_SWIMFORCE = -116.25 -- can be done every other frame
local UW_MAXSWIMSPEED = 0 -- how fast mario can be moving DOWN after a swim
local UW_MINSWIMSPEED = -120 -- how fast mario can be moving UP after a swim

local UW_SWIMACCELERATION = 42.1875
local UW_SWIMFRICTION = 28.125
local UW_SWIMSKIDACCELERATION = 112.5

-- Underwater:
-- Mario is underwater when his center is in a water tile.
-- Even when swimming above the top water tile, he will stay under water unless jumping with UP held
-- While in underwater mode and not in water (reaching the surface without jumping out) he can't swim up until re-entering a water tile
-- Leaving a watertile without jumping out sets his speed to UW_SURFACESPEED
-- Leaving a watertile with jumping out sets his speed to a minimum of UW_MINSURFACESPEED

-- local DOWNHILLWALKBONUS = 7.5

function movement:initialize(actor, args)
    Component.initialize(self, actor, args)

    self.actor.jumping = false

    self.actor.animationState = "grounded"

    self.actor.animationDirection = 1

    self.actor.pMeter = 0
    self.actor.pMeterTimer = 0
    self.actor.pMeterTime = 8/60

    self.actor.runAnimationFrame = 1
    self.actor.runAnimationTimer = 0

    self.actor.somerSaultFrame = 2
    self.actor.somerSaultFrameTimer = 0

    self.actor.shooting = false
    self.actor.shootTimer = 0

    self.actor:registerState("grounded", function(actor)

    end)

    self.actor:registerState("falling", function(actor)
        if controls3.cmdDown("jump") and self.actor.speed[2] < JUMPGRAVITYUNTIL then
            return "jumping"
        end
        -- otherwise handled by bottomCollision
    end)

    self.actor.state = ActorState:new(self.actor, "grounded", self.actor.states.grounded) -- maybe change this so it's a method on actor?
end

function movement:update(dt, actorEvent)
    if self.actor.shooting then
        self.actor.shootTimer = self.actor.shootTimer + dt

        if self.actor.shootTimer >= SHOOTTIME then
            self.actor.shooting = false
        end
    end

    if self.actor.state.name == "grounded" then
        if not controls3.cmdDown("left") and not controls3.cmdDown("right") then
            self.actor:friction(dt, FRICTION)
        end

        local maxSpeed = 0
        local acceleration = ACCELERATION
        local friction = FRICTION

        if controls3.cmdDown("left") or controls3.cmdDown("right") then
            maxSpeed = MAXSPEEDS[1]
        end

        if controls3.cmdDown("run") then
            maxSpeed = MAXSPEEDS[2]
        end

        if self.actor.pMeter == VAR("pMeterTicks") and controls3.cmdDown("run") then
            maxSpeed = MAXSPEEDS[3]
        end

        if self.actor.underWater then
            maxSpeed = UW_MAXWALKSPEED
            acceleration = UW_WALKACCELERATION
            fricton = UW_WALKFRICTION
        end

        -- Normal left/right acceleration
        accelerate(dt, self.actor, acceleration, maxSpeed)

        if math.abs(self.actor.speed[1]) > maxSpeed then
            self.actor:friction(dt, friction)
        end

        local skidAcceleration = SKIDACCELERATION

        if self.actor.underWater then
            skidAcceleration = UW_SKIDACCELERATION
        end

        skid(dt, self.actor, skidAcceleration)
    end

    if not self.actor.flying and (self.actor.state.name == "jumping" or self.actor.state.name == "falling") then
        accelerate(dt, self.actor, ACCELERATION, self.actor.maxSpeedJump or MAXSPEEDS[1])
        skid(dt, self.actor, SKIDACCELERATION)
    end

    -- P meter
    self.actor.pMeterTimer = self.actor.pMeterTimer + dt

    if self.actor.speed[1] == MAXSPEEDS[2] and self.actor.pMeter == 0 then
        self.actor.pMeterTime = PMETERTIMEUP
        self.actor.pMeterTimer = PMETERTIMEUP
    end

    -- Maintain fullspeed when pMeter full
    if self.actor.pMeter == VAR("pMeterTicks") and
        (not self.actor.onGround or
        (math.abs(self.actor.speed[1]) >= MAXSPEEDS[2] and
        controls3.cmdDown("run") and
        ((self.actor.speed[1] > 0 and controls3.cmdDown("right")) or (self.actor.speed[1] < 0 and controls3.cmdDown("left"))))) then
        self.actor.pMeterTimer = 0
        self.actor.pMeterTime = PMETERTIMEMARGIN
    end

    if not self.actor.flying then
        while self.actor.pMeterTimer >= self.actor.pMeterTime do
            self.actor.pMeterTimer = self.actor.pMeterTimer - self.actor.pMeterTime

            if self.actor.onGround and math.abs(self.actor.speed[1]) >= MAXSPEEDS[2] then
                if self.actor.pMeter < VAR("pMeterTicks") then
                    self.actor.pMeterTime = PMETERTIMEUP
                    self.actor.pMeter = self.actor.pMeter + 1
                end
            else
                if self.actor.pMeter > 0 then
                    self.actor.pMeterTime = PMETERTIMEDOWN
                    self.actor.pMeter = self.actor.pMeter - 1

                    if self.actor.pMeter == 0 then
                        self.actor.pMeterTime = PMETERTIMEUP
                    end
                end
            end
        end
    end

    if CHEAT("infinitePMeter") then
        self.actor.pMeter = VAR("pMeterTicks")
        self.actor.flyTimer = 0
    end

    -- self.actor.speed[1] = self.actor.groundSpeedX

    -- Adjust speed[1] if going downhill or uphill
    -- if self.actor.onGround then
    --     if self.actor.surfaceAngle > 0 then
    --         if self.actor.groundSpeedX > 0 then
    --             self.actor.speed[1] = self.actor.speed[1] + DOWNHILLWALKBONUS
    --         else
    --             self.actor.speed[1] = self.actor.speed[1] * math.cos(self.actor.surfaceAngle)
    --         end
    --     elseif self.actor.surfaceAngle < 0 then
    --         if self.actor.groundSpeedX < 0 then
    --             self.actor.speed[1] = self.actor.speed[1] - DOWNHILLWALKBONUS
    --         else
    --             self.actor.speed[1] = self.actor.speed[1] * math.cos(-self.actor.surfaceAngle)
    --         end
    --     end
    -- end

    actorEvent:setValue("gravity", VAR("gravity"), 0)
end

function movement:bottomCollision()
    if self.actor.state.name == "jumping" or self.actor.state.name == "falling" then
        self.actor:switchState("grounded")
    end
end

function movement:startFall()
    self.actor:switchState("falling")
end

function skid(dt, actor, friction)
    if controls3.cmdDown("right") and actor.speed[1] < 0 then
        actor.speed[1] = math.min(0, actor.speed[1] + friction*dt)
    end

    if controls3.cmdDown("left") and actor.speed[1] > 0 then
        actor.speed[1] = math.max(0, actor.speed[1] - friction*dt)
    end
end

function accelerate(dt, actor, acceleration, maxSpeed)
    if math.abs(actor.speed[1]) < maxSpeed then
        if controls3.cmdDown("left") and not controls3.cmdDown("right") and actor.speed[1] <= 0 then
            actor.speed[1] = math.max(-maxSpeed, actor.speed[1] - acceleration*dt)
        end

        if controls3.cmdDown("right") and not controls3.cmdDown("left") and actor.speed[1] >= 0 then
            actor.speed[1] = math.min(maxSpeed, actor.speed[1] + acceleration*dt)
        end
    end
end

return movement
