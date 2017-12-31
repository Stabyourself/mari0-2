PortalParticle = class("PortalParticle")

local PORTALPARTICLETIME = 1
local SPEEDCHANGE = 300
local RCHANGE = 40

function PortalParticle:initialize(x, y, r, color, t)
    self.x = x
    self.y = y
    self.r = r
    self.color = color
    
    self.tOffset = t
    
    self.timer = 0
    self.speed = 8
end

function PortalParticle:update(dt)
    self.timer = self.timer + dt + self.tOffset
    self.tOffset = 0
    
    self.r = self.r + (love.math.random()*2-1)*dt*RCHANGE
    self.speed = self.speed + (love.math.random()*2-1)*dt*SPEEDCHANGE
    
    self.x = self.x + math.cos(self.r)*self.speed*dt
    self.y = self.y + math.sin(self.r)*self.speed*dt
    
    return self.timer > PORTALPARTICLETIME
end

function PortalParticle:draw()
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], (1-self.timer/PORTALPARTICLETIME)*255)
    love.graphics.rectangle("fill", self.x-.5, self.y-.5, 1, 1)
end