local Character = class("SMB3Mario", Mario)

local ACCELERATION = 196.875 -- acceleration on ground

local NORMALGRAVITY = 1125
local JUMPGRAVITY = 225
local JUMPGRAVITYUNTIL = -120
local BUTTACCELERATION = 225 -- this is per 1/8*pi of downhill slope

local MAXSPEEDS = {90, 150, 210}
local MAXSPEEDFLY = 86.25

local FRICTION = 140.625 -- amount of speed that is substracted when not pushing buttons
local FRICTIONICE = 42.1875 -- duh
local FRICTIONBUTT = 277+7/9
local FRICTIONFLYSMALL = 56.25
local FRICTIONFLYBIG = 225

local FRICTIONSKID = 450 -- turnaround speed
local FRICTIONSKIDFLY = 675 -- turnaround speed while flying
local FRICTIONSKIDICE = 182.8125 -- turnaround speed on ice

local RUNANIMATIONTIME = 1.2

local JUMPFORCE = 256
local JUMPFORCEADD = 30.4 -- how much jumpforce is added at top speed (linear from 0 to topspeed)

local PMETERTIMEUP = 8/60
local PMETERTIMEDOWN = 24/60
local PMETERTIMEMARGIN = 16/60

local DOWNHILLWALKBONUS = 7.5

local FLYTIME = 4.25
local FLYINGASCENSION = -90
local FLOATASCENSION = 60

local FLYINGUPTIME = 16/60
local FLOATTIME = 16/60




function Character:initialize(...)
    Mario.initialize(self, ...)
end

function Character:spin() -- that's a good trick
    if not self.world.controlsEnabled then
        return
    end
    
    if self.char.canSpin and not self.spinning then
        if not cmdDown("down") then -- Make sure it's not colliding with any of the other states
            self.spinning = true
            self.spinTimer = 0
            self.spinDirection = self.animationDirection
        end
    end
end

function Character:star()
    if not self.world.controlsEnabled then
        return
    end
    
    self.starMan = true
    self.starTimer = 0
end

function Character:shoot()
    if not self.world.controlsEnabled then
        return
    end
    
    if self.char.canShoot and not self.shooting then
        if not self.ducking then -- Make sure it's not colliding with any of the other states
            -- This is where I'd spawn some fireballs.
            
            
            -- IF I HAD ANY
            
            self.shooting = true
            self.shootTimer = 0
        end
    end
end

return Character