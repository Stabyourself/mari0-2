local truffleShuffle = class("movement.truffleShuffle")

local MAXSPEED = 40
local ACCELERATION = 200

function truffleShuffle:initialize(actor, args)
    self.actor = actor
    self.args = args

    self:setup()
end

function truffleShuffle:setup()
    if self.actor.speed[1] == 0 then
        self.shuffleDir = -1
    else
        self.shuffleDir = math.sign(self.actor.speed[1])
    end

    self.maxSpeed = self.args.maxSpeed or MAXSPEED
    self.acceleration = self.args.acceleration or ACCELERATION
    
    if self.actor.speed[1] == 0 or self.args.startMax then
        self.actor.speed[1] = self.shuffleDir*self.maxSpeed
    end

    self.actor.animationDirection = math.sign(self.actor.speed[1])
end

function truffleShuffle:update(dt)
    -- update shuffleDir if something (like portals) made us move the other way
    if self.actor.speed[1] > 0 then
        self.shuffleDir = 1
    elseif self.actor.speed[1] < 0 then
        self.shuffleDir = -1
    end

    self.actor:accelerateTo(dt, self.shuffleDir*self.maxSpeed, self.maxSpeed)
    self.actor.animationDirection = math.sign(self.actor.speed[1])
end

function truffleShuffle:leftCollision()
    self.actor.speed[1] = -self.actor.speed[1]
end

function truffleShuffle:rightCollision()
    self.actor.speed[1] = -self.actor.speed[1]
end

return truffleShuffle