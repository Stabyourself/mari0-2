local Component = require "class.Component"
local swimming = class("smb3.swimming", Component)

local UW_MINSURFACESPEED = -45
local UW_SURFACEJUMPFORCE = -191.25

local UW_GRAVITY = 112.5 -- applied when moving downwards
local UW_SWIMGRAVITY = 225 -- applied when moving upwards
local UW_SWIMFORCE = -116.25 -- can be done every other frame
local UW_MAXUPSWIMSPEED = 0 -- how fast mario can be moving DOWN after a swim
local UW_MINUPSWIMSPEED = -120 -- how fast mario can be moving UP after a swim

local UW_MAXSWIMSPEED = 90
local UW_SWIMACCELERATION = 42.1875
local UW_SWIMFRICTION = 28.125
local UW_SWIMSKIDACCELERATION = 112.5

function swimming:initialize(actor, args)
    Component.initialize(self, actor, args)

    self.actor.upSwimCycles = 0

    self.actor:registerState("swimming", function(actor)

    end)
end

function swimming:update(dt, actorEvent)
    if self.actor.state.name == "swimming" then
        if not controls3.cmdDown("left") and not controls3.cmdDown("right") then
            self.actor:friction(dt, UW_SWIMFRICTION)
        end

        accelerate(dt, self.actor, UW_SWIMACCELERATION, UW_MAXSWIMSPEED)
        skid(dt, self.actor, UW_SWIMSKIDACCELERATION)

        local gravity
        if self.actor.cache.speed[2] >= 0 then
            gravity = UW_GRAVITY
        else
            gravity = UW_SWIMGRAVITY
        end

        actorEvent:setValue("gravity", gravity, 10)
    end
end

function swimming:jump(dt, actorEvent)
    if self.actor.underWater then
        self.actor.onGround = false

        actorEvent:bind("after", function(actor)
            actor.speed[2] = math.clamp(actor.cache.speed[2]+UW_SWIMFORCE, UW_MINUPSWIMSPEED, UW_MAXUPSWIMSPEED)
        end)

        if self.actor.upSwimCycles == 0 then
            self.actor.swimAnimationFrame = 1
        end

        if self.actor.swimAnimationFrame > self.actor.frameCounts.swimUp then
            self.actor.swimAnimationFrame = 1
        end

        self.actor.upSwimCycles = math.min(self.actor.upSwimCycles, 1) + 2

        self.actor:switchState("swimming")
    end
end

function swimming:bottomCollision()
    if self.actor.state.name == "swimming" then
        self.actor:switchState("grounded")
    end
end

function swimming:startFall()
    if self.actor.underWater then
        self.actor:switchState("swimming")
    end
end

return swimming
