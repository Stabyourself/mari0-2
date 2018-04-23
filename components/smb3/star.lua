local component = {}

local STARTIME = 7.45

local STARFRAMESLOWTIME = 1 -- see STARFRAMETIMESLOW

local STARFRAMETIME = 1/60
local STARFRAMETIMESLOW = 4/60 -- used during the last STARFRAMESLOWTIME seconds

local STARPALETTES = {
    convertPalette({
        {252, 252, 252},
        {  0,   0,   0},
        {216,  40,   0},
    }),
    
    convertPalette({
        {252, 252, 252},
        {  0,   0,   0},
        { 76, 220,  72},
    }),
    
    convertPalette({
        {252, 188, 176},
        {  0,   0,   0},
        {252, 152,  56},
    })
}

function component.setup(actor)
    actor.starred = true
    actor.starTimer = 0
    actor.somerSaultFrame = 2
    actor.somerSaultFrameTimer = 0
end

function component.update(actor, dt, actorEvent)
    actor.starTimer = actor.starTimer + dt
    
    -- get frame
    local palette
    if actor.starTimer >= STARTIME - STARFRAMESLOWTIME then
        palette = math.ceil(math.fmod(actor.starTimer, (#STARPALETTES+1)*STARFRAMETIMESLOW)/STARFRAMETIMESLOW)
    else
        palette = math.ceil(math.fmod(actor.starTimer, (#STARPALETTES+1)*STARFRAMETIME)/STARFRAMETIME)
    end
    
    if palette == 4 then
        actor.palette = actor.defaultPalette
    else
        actor.palette = STARPALETTES[palette]
    end
    
    if actor.starTimer >= STARTIME then
        actor.palette = actor.defaultPalette
        actor.starred = false

        actor:removeComponent(component)
    end
end

function component.jump(actor)
    if actor.onGround then
        actor.somerSaultFrame = 2
        actor.somerSaultFrameTimer = 0
    end
end

return component
