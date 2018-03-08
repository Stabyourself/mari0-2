Crosshair = class("Crosshair")

function Crosshair:initialize(mario)
    self.mario = mario
    self.target = {}
    self.origin = {}
    self.valid = false
    
    self.t = 0
end

function Crosshair:update(dt)
    self.t = self.t + dt
    
    prof.push("Raycast")
    local tileX, tileY, worldX, worldY, blockSide = self.mario.world:rayCast(self.origin.x/self.mario.world.tileSize, self.origin.y/self.mario.world.tileSize, self.angle)
    prof.pop()

    worldX, worldY = self.mario.world:mapToWorld(worldX, worldY)
    
    self.target.tileX = tileX
    self.target.tileY = tileY
    self.target.worldX = worldX
    self.target.worldY = worldY
    self.target.blockSide = blockSide
    self.target.angle = angle
    
    self.length = math.sqrt((self.origin.x-self.target.worldX)^2 + (self.origin.y-self.target.worldY)^2)
    
    self.valid = false
    
    prof.push("CheckPortalSurface")
    local x1, y1, x2, y2, angle = self.mario.world:checkPortalSurface(self.target.tileX, self.target.tileY, self.target.blockSide, self.target.worldX, self.target.worldY)
    prof.pop()
    
    self.target.angle = angle
    
    if x1 then
        local length = math.sqrt((x1-x2)^2+(y1-y2)^2)
        
        if length >= VAR("portalSize") then
            self.valid = true
        end
        
    end
end

function Crosshair:draw()
    if self.target then
        if self.valid then
            love.graphics.setColor(0, 1, 0)
        else
            love.graphics.setColor(1, 0, 0)
        end
        
        love.graphics.line(self.origin.x, self.origin.y, self.target.worldX, self.target.worldY)
    end
end

DottedCrosshair = class("DottedCrosshair", Crosshair)

DottedCrosshair.targetImg = love.graphics.newImage("img/crosshair-target.png")

DottedCrosshair.dotDistance = 16
DottedCrosshair.dotSize = 1
DottedCrosshair.fadeInDistance = 16
DottedCrosshair.fadeInLength = 12

function DottedCrosshair:initialize(mario)
    Crosshair.initialize(self, mario)
end

function DottedCrosshair:draw()
    if self.target then
        local dotCount = (self.length+self.dotSize)/self.dotDistance
        for i = 0, dotCount do
            local factor = 1/dotCount*(i+self.t%1)
            
            if factor <= 1 then
                local x = self.origin.x+(self.target.worldX-self.origin.x)*factor
                local y = self.origin.y+(self.target.worldY-self.origin.y)*factor
                
                local a = math.clamp(((factor*(self.length+self.dotSize))-self.fadeInDistance)/self.fadeInDistance, 0, 1)
                
                if self.valid then
                    love.graphics.setColor(0, 0.88, 0, a)
                else
                    love.graphics.setColor(1, 0, 0, a)
                end
                
                love.graphics.rectangle("fill", x-self.dotSize/2, y-self.dotSize/2, self.dotSize, self.dotSize)
            end
        end
        
        if self.valid then
            love.graphics.setColor(0, 0.88, 0, a)
        else
            love.graphics.setColor(1, 0, 0, a)
        end
        
        love.graphics.draw(self.targetImg, self.target.worldX, self.target.worldY, self.target.angle, 1, 1, 4, 8)
    end
end