local component = {}

local MAXSPEEDS = {90, 150, 210}
local JUMPTABLE = {
    {vel = 60, jumpForce = -206.25},
    {vel = 120, jumpForce = -213.75},
    {vel = 180, jumpForce = -221.25},
    {vel = math.huge, jumpForce = -236.25},
}
local JUMPGRAVITYUNTIL = -120
local JUMPGRAVITY = 225

function component.setup(actor)
    actor:registerState("jump", function(actor)
        if not cmdDown("jump") or actor.speed[2] >= JUMPGRAVITYUNTIL then
            return "fall"
        end
    end)
end

function component.update(actor, dt, actorEvent)
    if actor.state.name == "jump" then
        actorEvent:setValue("gravity", VAR("gravityJumping"), 10)
    end
end

function component.jump(actor, dt, actorEvent)
    if actor.onGround then
        actorEvent:bind("after", function(actor)
            actor.onGround = false
        end)

        actor.jumping = true
        
        -- Adjust jumpforce according to speed
        for i = 1, #JUMPTABLE do
            if math.abs(actor.speed[1]) <= JUMPTABLE[i].vel then
                actor.speed[2] = JUMPTABLE[i].jumpForce
                break
            end
        end
        
        -- Store how fast Mario is allowed to accelerate during the jump
        local maxSpeedJumps
        
        for i = 1, #MAXSPEEDS do
            if math.abs(actor.speed[1]) <= MAXSPEEDS[i] then
                maxSpeedJump = MAXSPEEDS[i]
                break
            end
        end
        
        if not maxSpeedJump then
            maxSpeedJump = MAXSPEEDS[#MAXSPEEDS]
        end
        
        actor.maxSpeedJump = maxSpeedJump
        
        actor:switchState("jump")
    end
end

return component
