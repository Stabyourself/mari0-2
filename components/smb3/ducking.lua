local Component = require "class.Component"
local ducking = class("smb3.ducking", Component)

local BUTTACCELERATION = 225 -- this is per 1/8*pi of downhill slope
local FRICTIONBUTT = 277+7/9

function ducking:initialize(actor, args)
    Component.initialize(self, actor, args)

    self.actor.ducking = false

    self.actor:registerState("buttSliding", function(actor)
        if controls3.cmdDown("right") or controls3.cmdDown("left") or (actor.speed[1] == 0 and actor.surfaceAngle == 0) then
            return "grounded"
        end
    end)
end

function ducking:update(dt)
    local wasDucking = self.actor.ducking

    if self.actor.onGround then
        if  controls3.cmdDown("down") and
            not controls3.cmdDown("left") and
            not controls3.cmdDown("right") and
            self.actor.state.name ~= "buttSliding" then
            if self.actor.surfaceAngle ~= 0 then -- check if buttslide
                self.actor:switchState("buttSliding")

                if self.actor.surfaceAngle > 0 then
                    self.actor.speed[1] = math.max(0, self.actor.speed[1])
                else
                    self.actor.speed[1] = math.min(0, self.actor.speed[1])
                end
            else
                self.actor.ducking = true

                -- Stop spinning in case
                self.actor.spinning = false
                self.actor.spinTimer = SPINTIME
            end
        else
            self.actor.ducking = false
        end
    end

    if wasDucking ~= self.actor.ducking then
        if self.actor.ducking then
            self.actor:changeSize(12, 12)
            self.actor.centerY = 30
        else
            self.actor:changeSize(12, 24)
            self.actor.centerY = 24
        end
    end

    if self.actor.state.name == "buttSliding" then
        local buttAcceleration = BUTTACCELERATION * (self.actor.surfaceAngle/(math.pi/8))

        self.actor.speed[1] = self.actor.speed[1] + buttAcceleration*dt

        if self.actor.surfaceAngle == 0 then
            self.actor:friction(dt, FRICTIONBUTT)
        end
    end
end

return ducking
