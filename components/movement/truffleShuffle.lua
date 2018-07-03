local Component = require "class.Component"
local truffleShuffle = class("movement.truffleShuffle", Component)

local MAXSPEED = 40
local ACCELERATION = 200

truffleShuffle.argList = {
    {"canStop", "boolean", false},
    {"dontTurnAnimation", "boolean", false},
    {"maxSpeed", "number", 40},
    {"acceleration", "number", 200},
    {"startSpeed", "number", function(self) return self.maxSpeed end},
}

function truffleShuffle:initialize(actor, args)
    Component.initialize(self, actor, args)

    self.kickSpeed = self.maxSpeed

    if self.actor.speed[1] == 0 then
        self.shuffleDir = -1
    else
        self.shuffleDir = math.sign(self.actor.speed[1])
    end

    self.actor.speed[1] = self.shuffleDir*self.startSpeed


    if not self.dontTurnAnimation then
        self.actor.animationDirection = self.shuffleDir
    end
end

function truffleShuffle:update(dt)
    -- update shuffleDir if something (like portals) made us move the other way
    if self.actor.speed[1] > 0 then
        self.shuffleDir = 1
    elseif self.actor.speed[1] < 0 then
        self.shuffleDir = -1
    end

    if self.actor.speed[1] ~= 0 or not self.canStop then
        self.actor:accelerateTo(dt, self.shuffleDir*self.maxSpeed, self.acceleration)

        if not self.dontTurnAnimation then
            self.actor.animationDirection = math.sign(self.actor.speed[1])
        end
    end
end

function truffleShuffle:leftCollision()
    if self.actor.cache.speed[1] < 0 then
        self.actor.speed[1] = -self.actor.cache.speed[1]
        self.shuffleDir = 1
    end
end

function truffleShuffle:rightCollision()
    if self.actor.cache.speed[1] > 0 then
        self.actor.speed[1] = -self.actor.cache.speed[1]
        self.shuffleDir = -1
    end
end

function truffleShuffle:kicked(dt, actorEvent, dir)
    self.actor.speed[1] = self.kickSpeed*dir
end

function truffleShuffle:unkicked()
    self.actor.speed[1] = 0
end

return truffleShuffle