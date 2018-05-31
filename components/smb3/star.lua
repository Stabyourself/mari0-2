local star = class("smb3.star")

function star:initialize(actor, args)
    self.actor = actor
    self.args = args

    self:setup()
end

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

function star:setup()
    self.actor.starred = true
    self.actor.starTimer = 0
    self.actor.somerSaultFrame = 2
    self.actor.somerSaultFrameTimer = 0
end

function star:update(dt, actorEvent)
    self.actor.starTimer = self.actor.starTimer + dt

    -- get frame
    local palette
    if self.actor.starTimer >= STARTIME - STARFRAMESLOWTIME then
        palette = math.ceil(math.fmod(self.actor.starTimer, (#STARPALETTES+1)*STARFRAMETIMESLOW)/STARFRAMETIMESLOW)
    else
        palette = math.ceil(math.fmod(self.actor.starTimer, (#STARPALETTES+1)*STARFRAMETIME)/STARFRAMETIME)
    end

    if palette == 4 then
        self.actor.palette = self.actor.defaultPalette
    else
        self.actor.palette = STARPALETTES[palette]
    end

    if self.actor.starTimer >= STARTIME then
        self.actor.palette = self.actor.defaultPalette
        self.actor.starred = false

        self.actor:removeComponent(self.class)
    end
end

function star:jump()
    if self.actor.onGround then
        self.actor.somerSaultFrame = 2
        self.actor.somerSaultFrameTimer = 0
    end
end

return star
