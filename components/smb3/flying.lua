local Component = require "class.Component"
local flying = class("smb3.flying", Component)

local FLYINGUPTIME = 16/60
local FLYTIME = 4.25
local MAXSPEEDFLY = 86.25
local MAXSPEEDS = {90, 150, 210}
local FLYINGASCENSION = -90
local ACCELERATION = 196.875
local FRICTIONFLYSMALL = 56.25
local FRICTIONFLYBIG = 225
local FRICTIONSKIDFLY = 675 -- turnaround speed while flying

function flying:initialize(actor, args)
    Component.initialize(self, actor, args)

    self.actor.flyTimer = FLYTIME
    self.actor.flying = false

    self.actor.flyAnimationFrame = 1
    self.actor.flyAnimationTimer = 0

    self.actor:registerState("flying", function(actor, actorState)
        if not actor.flying then
            return "falling"
        end

        if actorState.timer >= FLYINGUPTIME then
            return "falling"
        end
    end)
end

function flying:jump()
    if not self.actor.cache.onGround and self.actor.flying then
        self.actor:switchState("flying")
        self.actor.flyAnimationFrame = 1
    end

    if self.actor.pMeter == VAR("pMeterTicks") and not self.actor.flying then
        self.actor.flyTimer = 0
        self.actor.flying = true
    end
end

function flying:update(dt, actorEvent)
    if self.actor.flying then
        self.actor.flyTimer = self.actor.flyTimer + dt

        if self.actor.flyTimer >= FLYTIME then
            self.actor.flying = false
            self.actor.pMeter = 0
        end
    end

    if  (self.actor.flying and (self.actor.state.name == "jumping" or self.actor.state.name == "falling")) or
    self.actor.state.name == "flying" then
        if math.abs(self.actor.speed[1]) > MAXSPEEDFLY then
            if  self.actor.speed[1] > 0 and controls3.cmdDown("right") or
                self.actor.speed[1] < 0 and controls3.cmdDown("left") then
                self.actor:friction(dt, FRICTIONFLYSMALL, MAXSPEEDFLY)
            else
                self.actor:friction(dt, FRICTIONFLYBIG, MAXSPEEDFLY)
            end
        end

        if self.actor.state.name == "flying" then
            accelerate(dt, self.actor, ACCELERATION, MAXSPEEDFLY)
            self.actor.speed[2] = FLYINGASCENSION
            actorEvent:setValue("gravity", 0, 10)
        else
            local maxSpeed = math.min(MAXSPEEDS[2], self.actor.maxSpeedJump or MAXSPEEDS[1])

            accelerate(dt, self.actor, ACCELERATION, maxSpeed)
        end

        skid(dt, self.actor, FRICTIONSKIDFLY)
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

function skid(dt, actor, friction)
    if controls3.cmdDown("right") and actor.speed[1] < 0 then
        actor.speed[1] = math.min(0, actor.speed[1] + friction*dt)
    end

    if controls3.cmdDown("left") and actor.speed[1] > 0 then
        actor.speed[1] = math.max(0, actor.speed[1] - friction*dt)
    end
end

return flying
