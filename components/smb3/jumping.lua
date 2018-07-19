local Component = require "class.Component"
local jumping = class("smb3.jumping", Component)

local MAXSPEEDS = {90, 150, 210}
local JUMPTABLE = {
    {vel = 60, jumpForce = -206.25},
    {vel = 120, jumpForce = -213.75},
    {vel = 180, jumpForce = -221.25},
    {vel = math.huge, jumpForce = -236.25},
}
local JUMPGRAVITYUNTIL = -120

function jumping:initialize(actor, args)
    Component.initialize(self, actor, args)

    self.actor:registerState("jumping", function(actor)
        if not controls3.cmdDown("jump") or actor.speed[2] >= JUMPGRAVITYUNTIL then
            return "falling"
        end
    end)
end

function jumping:update(dt, actorEvent)
    if self.actor.state.name == "jumping" then
        actorEvent:setValue("gravity", VAR("gravityJumping"), 10)
    end
end

function jumping:jump(dt, actorEvent)
    if self.actor.cache.onGround then
        self.actor.onGround = false

        self.actor.jumping = true

        -- Adjust jumpforce according to speed
        for i = 1, #JUMPTABLE do
            if math.abs(self.actor.speed[1]) <= JUMPTABLE[i].vel then
                self.actor.speed[2] = JUMPTABLE[i].jumpForce
                break
            end
        end

        -- Store how fast Mario is allowed to accelerate during the jump
        local maxSpeedJump

        for i = 1, #MAXSPEEDS do
            if math.abs(self.actor.speed[1]) <= MAXSPEEDS[i] then
                maxSpeedJump = MAXSPEEDS[i]
                break
            end
        end

        if not maxSpeedJump then
            maxSpeedJump = MAXSPEEDS[#MAXSPEEDS]
        end

        self.actor.maxSpeedJump = maxSpeedJump

        self.actor:switchState("jumping")
    end
end

return jumping
