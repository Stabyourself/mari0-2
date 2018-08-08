PortalThing = require((...):gsub('%.Portal$', '') .. ".PortalThing")
PortalParticle = require((...):gsub('%.Portal$', '') .. ".PortalParticle")
local Portal = class("Portal")

local baseImg = love.graphics.newImage("img/portal-base.png")
local glowImg = love.graphics.newImage("img/portal-glow.png")

local thingImg = love.graphics.newImage("img/portal-thing.png")
local thingSmallImg = love.graphics.newImage("img/portal-thing-small.png")
local thingMediumImg = love.graphics.newImage("img/portal-thing-medium.png")

local PORTALANIMATIONTIME = 1.5
local PORTALMEDIUMLAG = 0.06
local PORTALSMALLLAG = 0.15
local PORTALTHINGS = 3
local PORTALTHINGDIFF = math.pi*2/PORTALTHINGS
local PORTALPARTICLETIME = 0.1

function Portal:initialize(world, x1, y1, x2, y2, color)
    self.x1 = x1
    self.y1 = y1
    self.x2 = x2
    self.y2 = y2

    self:updatePosition()

    self.color = color

    self.open = false

    self.openProgress = 0
    self.timer = 0
    self.openTimer = 0
    self.particleTimer = 0
    self.particles = {}

    self.portalThings = {}

    for i = 1, PORTALTHINGS do
        for j = 1, 3 do
            local img = thingImg
            local offset = (i-1)*PORTALTHINGDIFF

            if j == 2 then
                img = thingMediumImg
                offset = offset - math.pi*PORTALMEDIUMLAG
            end

            if j == 3 then
                img = thingSmallImg
                offset = offset - math.pi*PORTALSMALLLAG
            end

            table.insert(self.portalThings, PortalThing:new(img, offset))
        end
    end
end

function Portal:updatePosition() -- from points
    self.angle = math.atan2(self.y2-self.y1, self.x2-self.x1)
    self.size = math.sqrt((self.x1-self.x2)^2 + (self.y1-self.y2)^2)
end

function Portal:backwardsUpdatePosition() -- from angle
    local cX = (self.x2+self.x1)/2
    local cY = (self.y2+self.y1)/2

    self.x1 = -math.cos(self.angle)*self.size/2+cX
    self.x2 = -math.cos(self.angle+math.pi)*self.size/2+cX

    self.y1 = -math.sin(self.angle)*self.size/2+cY
    self.y2 = -math.sin(self.angle+math.pi)*self.size/2+cY
end

function Portal:update(dt)
    self.openTimer = math.min(1, self.openTimer + dt*4)
    self.openProgress = Easing.outQuad(self.openTimer, 0, 0.7, 1)+0.3

    self.timer = self.timer + dt

    -- Particles
    updateGroup(self.particles, dt)

    if self.open then
        self.particleTimer = self.particleTimer + dt

        while self.particleTimer >= PORTALPARTICLETIME do
            self.particleTimer = self.particleTimer - PORTALPARTICLETIME

            local dist = (love.math.random()-.5)*(self.size-3)*self.openProgress

            local r = -math.pi/2

            table.insert(self.particles, PortalParticle:new(dist, 0, r, self.color))
        end
    end

    -- Update the things

    local a = math.fmod(self.timer, PORTALANIMATIONTIME)/PORTALANIMATIONTIME*math.pi*2

    for _, portalThing in ipairs(self.portalThings) do
        portalThing:update(dt, a)
    end
end

function Portal:draw(side)
    love.graphics.push()

    love.graphics.translate(self.x1, self.y1)
    love.graphics.rotate(self.angle)
    love.graphics.translate(self.size/2, 0)


    if side == "background" then
        local glowI = math.fmod(self.timer*PORTALTHINGS*0.5, PORTALANIMATIONTIME)/PORTALANIMATIONTIME*math.pi*2
        local glowA = math.sin(glowI)*0.2+0.8

        if self.open then
            love.graphics.setColor(1, 1, 1, glowA)
            love.graphics.draw(glowImg, 0, 0, 0, math.max(0, self.size*self.openProgress-2), 1, .5, 16)
        end

    else
        for _, particle in ipairs(self.particles) do
            particle:draw()
        end

        love.graphics.setColor(self.color:rgb())
        love.graphics.draw(baseImg, 0, 0, 0, self.size*self.openProgress, 1, .5, 1)
    end

    local mult = (self.size/2*self.openProgress - 2)

    for _, portalThing in ipairs(self.portalThings) do
        portalThing:draw(side, self.color, mult)
    end

    love.graphics.setColor(1, 1, 1)

    love.graphics.pop()
end

function Portal:connectTo(portal)
    self.connectsTo = portal
    self.open = true
end

function Portal:stencilRectangle(way)
    love.graphics.push()
    love.graphics.translate(self.x1, self.y1)
    love.graphics.rotate(self.angle)

    local x, y, w, h = -32, 0, self.size+64, 32 -- in (DON'T draw those pixels

    if way == "out" then
        x, y, w, h = -32, -32, self.size+64, 32 -- out (DO draw those pixels)
    end

    love.graphics.rectangle("fill", x, y, w, h)

    love.graphics.pop()
end

return Portal
