local component = {}

local MAXSPEEDS = {90, 150, 210}
local ANIMATIONSPEEDS = {1/4*60, 1/3*60, 1/2*60, 1*60}

local FLYANIMATIONTIME = 4/60
local FLOATANIMATIONTIME = 4/60

local SPINTIME = 19/60
local SPINFRAMETIME = 4/60

local STARFRAMETIME = 4/60
local SOMERSAULTTIME = 2/60

local SHOOTTIME = 12/60

local STARPALETTES = {
    {
        {252/255, 252/255, 252/255},
        {  0/255,   0/255,   0/255},
        {216/255,  40/255,   0/255},
    },
    
    {
        {252/255, 252/255, 252/255},
        {  0/255,   0/255,   0/255},
        { 76/255, 220/255,  72/255},
    },
    
    {
        {252/255, 188/255, 176/255},
        {  0/255,   0/255,   0/255},
        {252/255, 152/255,  56/255},
    }
}

function component.setup(actor, dt, actorEvent, args)
    actor.img = actor.actorTemplate.img
    actor.quadWidth = args.quadWidth
    actor.quadHeight = args.quadWidth

    actor.centerX = args.centerX
    actor.centerY = args.centerY
    
    actor.standardPalette = args["color"] or {
        {252, 188, 176},
        {216,  40,   0},
        {  0,   0,   0},
    }

    convertPalette(actor.standardPalette)
    
    actor.palette = actor.standardPalette
    
    actor.quadList = {}
    actor.frames = args["frames"]
    actor.frameCounts = {}

    for y = 1, 5 do
        actor.quadList[y] = {}
        local x = 0
        
        for _, name in ipairs(actor.frames) do
            local quad = love.graphics.newQuad(x*actor.quadWidth, (y-1)*actor.quadHeight, actor.quadWidth, actor.quadHeight, actor.img[1]:getWidth(), actor.img[1]:getHeight())
            
            if actor.quadList[y][name] then
                if type(actor.quadList[y][name]) ~= "table" then
                    actor.quadList[y][name] = {actor.quadList[y][name]}
                end
                
                table.insert(actor.quadList[y][name], quad)
                actor.frameCounts[name] = actor.frameCounts[name] + 1
            else
                actor.quadList[y][name] = quad
                actor.frameCounts[name] = 1
            end
                
            x = x + 1
        end
    end
    
    actor.quad = actor.quadList[3].idle
end

function component.postUpdate(actor, dt)
    animation(actor, dt)
end

function animation(actor, dt)
    -- Image updating for star
    if actor.starred then
        -- get frame
        local palette = math.ceil(math.fmod(actor.starTimer, (#STARPALETTES+1)*STARFRAMETIME)/STARFRAMETIME)
        
        if palette == 4 then
            actor.palette = actor.standardPalette
        else
            actor.palette = STARPALETTES[palette]
        end
    end
    
    if actor.hasPortalGun then -- look towards portalGunAngle
        if math.abs(actor.portalGunAngle-actor.angle) <= math.pi*.5 then
            actor.animationDirection = 1
        else
            actor.animationDirection = -1
        end
        
    else -- look towards last pressed direction
        if cmdDown("left") then
            actor.animationDirection = -1
        elseif cmdDown("right") then
            actor.animationDirection = 1
        end
    end
    
    local frame = false
    
    if actor.spinning and (not actor.starred or (actor.state.name ~= "jump" and actor.state.name ~= "fall"))  then
        if actor.onGround then
            actor.animationState = "spin"
        else
            actor.animationState = "spinAir"
        end
        
        actor.animationDirection = actor.spinDirection
        
        -- calculate spin frame from spinTimer
        frame = 1+math.floor(math.fmod(actor.spinTimer, actor.frameCounts.spin*SPINFRAMETIME)/SPINFRAMETIME)

    elseif actor.shooting and (not actor.starred or (actor.state.name ~= "jump" and actor.state.name ~= "fall")) then
        if actor.onGround then
            actor.animationState = "shoot"
        else
            actor.animationState = "shootAir"
        end
        
        frame = math.ceil(actor.shootTimer/SHOOTTIME*actor.frameCounts.shoot)

    elseif actor.ducking then
        actor.animationState = "duck"
        
    elseif actor.state.name == "idle" then
        actor.animationState = "idle"
        
    elseif actor.state.name == "skid" then
        actor.animationState = "skid"
        
    elseif actor.state.name == "stop" or actor.state.name == "run" then
        if math.abs(actor.speed[1]) >= MAXSPEEDS[3] then
            actor.animationState = "sprint"
        else
            actor.animationState = "run"
        end
        
    elseif actor.flying and (actor.state.name == "jump" or actor.state.name == "fly" or actor.state.name == "fall") then
        actor.animationState = "fly"
    
    elseif actor.state.name == "buttSlide" then
        actor.animationState = "buttSlide"
        
    elseif actor.starred and actor.frameCounts.somerSault then
        actor.animationState = "somerSault"
        
    elseif actor.state.name == "float" then
        actor.animationState = "float"
        
    elseif actor.state.name == "jump" or actor.state.name == "fall" then
        if not actor.quadList.canFly and actor.pMeter == VAR("pMeterTicks") then
            actor.animationState = "fly"
        elseif (not actor.quadList.canFly and actor.maxSpeedJump == MAXSPEEDS[3]) or actor.flying then
            actor.animationState = "fly"
        else
            if actor.speed[2] < 0 then
                actor.animationState = "jump"
            else
                actor.animationState = "fall"
            end
        end
        
    end

    
    -- Running animation
    if (actor.animationState == "run" or actor.animationState == "sprint") then
        local animationspeed

        if math.abs(actor.speed[1]) >= MAXSPEEDS[3] then -- sprint speed
            animationspeed = ANIMATIONSPEEDS[4]
        elseif math.abs(actor.speed[1]) > MAXSPEEDS[2] then -- sprint speed
            animationspeed = ANIMATIONSPEEDS[3]
        elseif math.abs(actor.speed[1]) > MAXSPEEDS[1] then -- sprint speed
            animationspeed = ANIMATIONSPEEDS[2]
        else
            animationspeed = ANIMATIONSPEEDS[1]
        end
        
        actor.runAnimationTimer = actor.runAnimationTimer + animationspeed*dt
        
        while actor.runAnimationTimer > 1 do
            actor.runAnimationTimer = actor.runAnimationTimer - 1
            actor.runAnimationFrame = actor.runAnimationFrame + 1
            
            local runFrames = actor.frameCounts.run

            if actor.runAnimationFrame > runFrames then
                actor.runAnimationFrame = actor.runAnimationFrame - runFrames
            end
        end
            
        frame = actor.runAnimationFrame
    end
    
    -- Flying animation
    if actor.animationState == "fly" then
        local flyFrames = actor.frameCounts.fly
        
        if flyFrames > 1 then
            if actor.state.name == "fall" then
                actor.flyAnimationFrame = 2
            else
                actor.flyAnimationTimer = actor.flyAnimationTimer + dt
                while actor.flyAnimationTimer > FLYANIMATIONTIME do
                    actor.flyAnimationTimer = actor.flyAnimationTimer - FLYANIMATIONTIME
                    actor.flyAnimationFrame = actor.flyAnimationFrame + 1
                    
                    if actor.flyAnimationFrame > flyFrames then
                        actor.flyAnimationFrame = flyFrames -- don't reset to the start
                    end
                end
            end
            
            frame = actor.flyAnimationFrame
        end
    end
    
    -- Float animation
    if actor.animationState == "float" then
        actor.floatAnimationTimer = actor.floatAnimationTimer + dt
        while actor.floatAnimationTimer > FLYANIMATIONTIME do
            actor.floatAnimationTimer = actor.floatAnimationTimer - FLYANIMATIONTIME
            actor.floatAnimationFrame = actor.floatAnimationFrame + 1

            local floatFrames = actor.frameCounts.float
            if actor.floatAnimationFrame > floatFrames then
                actor.floatAnimationFrame = floatFrames -- don't reset to the start
            end
        end
        
        frame = actor.floatAnimationFrame
    end

    -- Somersault animation
    if actor.starred and (actor.state.name == "jump" or actor.state.name == "fall") then
        local somersaultFrames = actor.frameCounts.somerSault

        actor.somerSaultFrameTimer = actor.somerSaultFrameTimer + dt
        
        while actor.somerSaultFrameTimer > SOMERSAULTTIME do
            actor.somerSaultFrameTimer = actor.somerSaultFrameTimer - SOMERSAULTTIME
            
            actor.somerSaultFrame = actor.somerSaultFrame + 1
            if actor.somerSaultFrame > somersaultFrames then
                actor.somerSaultFrame = 1
            end
        end

        frame = actor.somerSaultFrame
    end
    
    -- Make sure to properly use the tables if it's an animationState with frames
    if frame then
        actor.quad = actor.quadList[getAngleFrame(actor)][actor.animationState][frame]
    else
        actor.quad = actor.quadList[getAngleFrame(actor)][actor.animationState]
    end
    
    assert(type(actor.quad) == "userdata", "The state \"" .. actor.animationState .. "\" seems to not be have a quad set up correctly. (attempted frame was \"" .. tostring(frame) .. "\")")
end

function getAngleFrame(actor)
    if not actor.hasPortalGun then
        return 5
    end

    local angle = actor.portalGunAngle-actor.angle
    
    if angle > math.pi*.5 then
        angle = math.pi - angle
    elseif angle < -math.pi*.5 then
        angle = -math.pi - angle
    end
    
    if angle < -math.pi*0.375 then
        return 1
    elseif angle < -math.pi*0.125 then
        return 2
    elseif angle < math.pi*0.125  then
        return 3
    elseif angle < math.pi*0.375 then
        return 4
    else -- Downward frame looks dumb
        return 4
    end
end

return component
