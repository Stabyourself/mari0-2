PortalParticle = class("PortalParticle")

local PORTALPARTICLETIME = 1
local SPEEDCHANGE = 300
local RCHANGE = 40

function PortalParticle:initialize(x, y, r, color)
    self.x = x
    self.y = y
    self.angle = r
    self.color = color
    
    self.timer = 0
    self.speed = 8
end

function PortalParticle:update(dt)
    self.timer = self.timer + dt
    self.tOffset = 0
    
    self.angle = self.angle + (love.math.random()*2-1)*dt*RCHANGE
    self.speed = self.speed + (love.math.random()*2-1)*dt*SPEEDCHANGE
    
    self.x = self.x + math.cos(self.angle)*self.speed*dt
    self.y = self.y + math.sin(self.angle)*self.speed*dt
    
    return self.timer > PORTALPARTICLETIME
end

function PortalParticle:draw()
    local r, g, b = self.color:rgb()
    local glowA = 1-self.timer/PORTALPARTICLETIME
    
    love.graphics.setColor(r, g, b, glowA)
    love.graphics.rectangle("fill", self.x-.5, self.y-.5, 1, 1)
end