Portal = class("Portal")

Portal.baseImg = love.graphics.newImage("img/portal-base.png")
Portal.glowImg = love.graphics.newImage("img/portal-glow.png")

Portal.thingImg = love.graphics.newImage("img/portal-thing.png")
Portal.thingSmallImg = love.graphics.newImage("img/portal-thing-small.png")

local PORTALANIMATIONTIME = 1.5
local PORTALDOTLAG = 0.15
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
    
    self.timer = 0
    self.openTimer = 0
    self.particleTimer = 0
    self.particles = {}
end

function Portal:updatePosition()
    self.r = math.atan2(self.y2-self.y1, self.x2-self.x1)
    self.size = math.sqrt((self.x1-self.x2)^2 + (self.y1-self.y2)^2)
end

function Portal:backwardsUpdatePosition()
    local cX = (self.x2+self.x1)/2
    local cY = (self.y2+self.y1)/2
    
    self.x1 = -math.cos(self.r)*self.size/2+cX
    self.x2 = -math.cos(self.r+math.pi)*self.size/2+cX
    
    self.y1 = -math.sin(self.r)*self.size/2+cY
    self.y2 = -math.sin(self.r+math.pi)*self.size/2+cY
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
            local diff = self.particleTimer - PORTALPARTICLETIME
            self.particleTimer = diff
            
            local dist = (love.math.random()-.5)*(self.size-3)*self.openProgress
            
            local r = -math.pi/2
            
            table.insert(self.particles, PortalParticle:new(dist, 0, r, self.color, diff))
        end
    end
    
    -- Update the things (the ting goes boom kakakakaka)
    
    local a = math.fmod(self.timer, PORTALANIMATIONTIME)/PORTALANIMATIONTIME*math.pi*2
    
    self.thingList = {background = {}, foreground = {}}
    
    for i = 1, PORTALTHINGS do
        for j = 1, 2 do
            local a = a + (i-1)*PORTALTHINGDIFF
            
            if j == 2 then
                a = a - math.pi*PORTALDOTLAG
            end
            
            a = math.fmod(a, math.pi*2)
            
            local insertInto = self.thingList.background
            local diff = math.abs(a-math.pi)/math.pi
            
            if diff < 0.5 then
                insertInto = self.thingList.foreground
            end
            
            table.insert(insertInto, {
                a = a,
                diff = diff,
                small = (j == 2)
            })
        end
    end
end

function Portal:draw(side)
    love.graphics.push()
    
    love.graphics.translate(self.x1, self.y1)
    love.graphics.rotate(self.r)
    love.graphics.translate(self.size/2, 0)
    
    if side == "background" then
        local glowI = math.fmod(self.timer*PORTALTHINGS*0.5, PORTALANIMATIONTIME)/PORTALANIMATIONTIME*math.pi*2
        local glowA = math.sin(glowI)*0.2+0.8
        
        if self.open then
            local r, g, b = Color.lighten(self.color, 0.7)
            love.graphics.setColor(r, g, b, 255*glowA)
            love.graphics.draw(self.glowImg, 0, 0, 0, math.max(0, self.size*self.openProgress-2), 1, .5, 8)
        end
        
        for _, v in ipairs(self.thingList.background) do
            self:drawThing(v.a, v.small)
        end
        
    else
        for _, v in ipairs(self.particles) do
            v:draw()
        end
        
        love.graphics.setColor(self.color)
        love.graphics.draw(self.baseImg, 0, 0, 0, self.size*self.openProgress, 1, .5, 1)
    
        for _, v in ipairs(self.thingList.foreground) do
            self:drawThing(v.a, v.small)
        end
    end
    
    love.graphics.pop()
end

function Portal:drawThing(a, small)
    --darken based on distance to "front"
    local closeness = math.abs(a-math.pi)/math.pi
    
    local r, g, b = unpack(self.color)
    local darken = (closeness)*0.6
    love.graphics.setColor(Color.darken(r, g, b, darken))
    
    local dist = (self.size/2*self.openProgress - 2)
    
    local x = math.sin(a)
    
    -- make portal more oval shaped by squaring the result
    if x > 0 then
        x = 1-(1-x)^1.5
    else
        x = -(1-(1+x)^1.5)
    end
    
    x = x*dist
    
    local sx = (1-(math.abs(x)/dist))*0.7+0.3
    
    --turn around on the way to left
    if a > math.pi*0.5 and a < math.pi*1.5 then
        sx = -sx
    end
    
    if not small then
        love.graphics.draw(self.thingImg, x, 0, 0, sx, 1, 5, 3)
    else
        love.graphics.draw(self.thingSmallImg, x, 0, 0, sx, 1, 1, 2)
    end
end

function Portal:connectTo(portal)
    self.connectsTo = portal
    self.open = true
end

function Portal:stencilRectangle(way, method)
    love.graphics.push()
    love.graphics.translate(self.x1, self.y1)
    love.graphics.rotate(self.r)
    if way == "in" then
        love.graphics.rectangle(method or "fill", -32, 0, self.size+64, 32)
    else
        love.graphics.rectangle(method or "fill", -32, -32, self.size+64, 32)
    end
    love.graphics.pop()
end