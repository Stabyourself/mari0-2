local movement = class("smb3.movement", Component)

local ACCELERATION = 196.875 -- acceleration on ground

local JUMPGRAVITYUNTIL = -120

local MAXSPEEDS = {90, 150, 210}

local FRICTION = 140.625 -- amount of speed that is substracted when not pushing buttons
-- local FRICTIONICE = 42.1875 -- duh
-- local FRICTIONFLYSMALL = 56.25
-- local FRICTIONFLYBIG = 225

local FRICTIONSKID = 450 -- turnaround speed
-- local FRICTIONSKIDFLY = 675 -- turnaround speed while flying
-- local FRICTIONSKIDICE = 182.8125 -- turnaround speed on ice

local PMETERTIMEUP = 8/60
local PMETERTIMEDOWN = 24/60
local PMETERTIMEMARGIN = 16/60

-- local DOWNHILLWALKBONUS = 7.5

function movement:initialize(actor, args)
    Component.initialize(self, actor, args)

    self.actor.jumping = false

    self.actor.animationState = "idle"

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

    self.actor:registerState("idle", function(actor)
        if cmdDown("right") or cmdDown("left") then
            return "run"
        end

        if self.actor.speed[1] ~= 0 then
            return "stop"
        end
    end)

    self.actor:registerState("stop", function(actor)
        if cmdDown("right") or cmdDown("left") then
            return "run"
        end

        if self.actor.speed[1] == 0 then
            return "idle"
        end
    end)

    self.actor:registerState("run", function(actor)
        if not cmdDown("right") and not cmdDown("left") then
            return "stop"
        end

        if  self.actor.speed[1] > 0 and cmdDown("left") or
            self.actor.speed[1] < 0 and cmdDown("right") then
            return "skid"
        end
    end)

    self.actor:registerState("skid", function(actor)
        if self.actor.speed[1] == 0 then
            return "idle"
        end

        if  (self.actor.speed[1] < 0 and cmdDown("left") and not cmdDown("right")) or
            (self.actor.speed[1] > 0 and cmdDown("right") and not cmdDown("right")) or
            (self.actor.speed[1] > 0 and not cmdDown("left")) or
            (self.actor.speed[1] < 0 and not cmdDown("right")) then
            return "run"
        end
    end)

    self.actor:registerState("fall", function(actor)
        if cmdDown("jump") and self.actor.speed[2] < JUMPGRAVITYUNTIL then
            return "jump"
        end
        -- otherwise handled by bottomCollision
    end)

    self.actor.state = ActorState:new(self.actor, "idle", self.actor.states.idle) -- maybe change this
end

function movement:update(dt, actorEvent)
    if self.actor.shooting then
        self.actor.shootTimer = self.actor.shootTimer + dt

        if self.actor.shootTimer >= SHOOTTIME then
            self.actor.shooting = false
        end
    end

    if self.actor.state.name == "stop" then
        self.actor:friction(dt, FRICTION)
    end

    if self.actor.state.name == "run" then
        local maxSpeed = 0

        if cmdDown("left") or cmdDown("right") then
            maxSpeed = MAXSPEEDS[1]
        end

        if cmdDown("run") then
            maxSpeed = MAXSPEEDS[2]
        end

        if self.actor.pMeter == VAR("pMeterTicks") and cmdDown("run") then
            maxSpeed = MAXSPEEDS[3]
        end

        if not self.actor.onGround then
            maxSpeed = self.actor.maxSpeedJump or MAXSPEEDS[1]
        end

        -- Normal left/right acceleration
        accelerate(dt, self.actor, ACCELERATION, maxSpeed)

        if math.abs(self.actor.speed[1]) > maxSpeed then
            self.actor:friction(dt, FRICTION)
        end
    end

    if self.actor.state.name == "skid" then
        skid(dt, self.actor, FRICTIONSKID)
    end

    if not self.actor.flying and (self.actor.state.name == "jump" or self.actor.state.name == "fall") then
        accelerate(dt, self.actor, ACCELERATION, self.actor.maxSpeedJump or MAXSPEEDS[1])
        skid(dt, self.actor, FRICTIONSKID)
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
        cmdDown("run") and
        ((self.actor.speed[1] > 0 and cmdDown("right")) or (self.actor.speed[1] < 0 and cmdDown("left"))))) then
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
    if self.actor.state.name == "jump" or self.actor.state.name == "fall" then
        self.actor:switchState("idle")
    end
end

function movement:startFall()
    self.actor:switchState("fall")
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

return movement
