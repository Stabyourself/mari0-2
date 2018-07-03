local Crosshair = require("class.Crosshair")
local DottedCrosshair = class("DottedCrosshair", Crosshair)

DottedCrosshair.targetImg = love.graphics.newImage("img/crosshair-target.png")

DottedCrosshair.dotDistance = 16
DottedCrosshair.dotSize = 1
DottedCrosshair.fadeInDistance = 16
DottedCrosshair.fadeInLength = 12

function DottedCrosshair:initialize(mario)
    Crosshair.initialize(self, mario)
end

function DottedCrosshair:draw()
    if not self.target.valid then
        return
    end

    local dotCount = (self.length+self.dotSize)/self.dotDistance

    for i = 0, dotCount do
        local factor = 1/dotCount*(i+self.t%1)

        if factor <= 1 - (self.dotSize/2)/self.length then
            local x = self.origin.x+(self.target.worldX-self.origin.x)*factor
            local y = self.origin.y+(self.target.worldY-self.origin.y)*factor

            local a = math.clamp(((factor*(self.length+self.dotSize))-self.fadeInDistance)/self.fadeInDistance, 0, 1)

            if self.target.portalPossible then
                love.graphics.setColor(0, 0.88, 0, a)
            else
                love.graphics.setColor(1, 0, 0, a)
            end

            love.graphics.rectangle("fill", x-self.dotSize/2, y-self.dotSize/2, self.dotSize, self.dotSize)
        end
    end

    if self.target.portalPossible then
        love.graphics.setColor(0, 0.88, 0, a)
    else
        love.graphics.setColor(1, 0, 0, a)
    end

    love.graphics.draw(self.targetImg, self.target.worldX, self.target.worldY, self.target.angle, 1, 1, 4, 8)
end

return DottedCrosshair
