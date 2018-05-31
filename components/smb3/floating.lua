local floating = class("smb3.floating")

local FLOATASCENSION = 60
local FLOATTIME = 16/60

local MAXSPEEDFLY = 86.25
local ACCELERATION = 196.875
local FRICTIONFLYSMALL = 56.25
local FRICTIONFLYBIG = 225
local FRICTIONSKIDFLY = 675 -- turnaround speed while flying

function floating:initialize(actor, args)
    self.actor = actor
    self.args = args

    self:setup()
end

function floating:setup()
    self.actor.floatAnimationFrame = 1
    self.actor.floatAnimationTimer = 0

    self.actor:registerState("float", function(actor, actorState)
        if actorState.timer >= FLOATTIME then
            return "fall"
        end
    end)
end

function floating:update(dt)
    if self.actor.state.name == "float" then
        if math.abs(self.actor.speed[1]) > MAXSPEEDFLY then
            if  self.actor.speed[1] > 0 and cmdDown("right") or
                self.actor.speed[1] < 0 and cmdDown("left") then
                self.actor:friction(dt, FRICTIONFLYSMALL, MAXSPEEDFLY)
            else
                self.actor:friction(dt, FRICTIONFLYBIG, MAXSPEEDFLY)
            end
        end

        accelerate(dt, self.actor, ACCELERATION, MAXSPEEDFLY)

        skid(dt, self.actor, FRICTIONSKIDFLY)

        self.actor.speed[2] = FLOATASCENSION
    end
end

function floating:jump()
    if not self.actor.flying and not self.actor.onGround and self.actor.speed[2] > 0 then
        self.actor:switchState("float")
        self.actor.floatAnimationTimer = 0
        self.actor.floatAnimationFrame = 1
    end
end

function floating:bottomCollision()
    if self.actor.state.name == "float" then
        self.actor:switchState("idle")
    end
end

return floating
