local Camera = require "lib.Camera"

local Viewport = class("Viewport")

function Viewport:initialize(level, x, y, w, h, target)
    self.level = level
    self.camera = Camera.new(0, 0, w, h, x, y)
    self.target = target

    if self.target then
        self.camera:lookAt(self.target.x, self.target.y)
    end
end

function Viewport:draw()

end

function Viewport:update(dt)
    if self.target then
        -- Horizontal
        local pX = self.target.x + self.target.width/2
        local pXr = pX - self.camera.x

        if pXr > RIGHTSCROLLBORDER then
            self.camera.x = self.camera.x + VAR("cameraScrollRate")*dt

            if pX - self.camera.x < RIGHTSCROLLBORDER then
                self.camera.x = pX - RIGHTSCROLLBORDER
            end

        elseif pXr < LEFTSCROLLBORDER then
            self.camera.x = self.camera.x - VAR("cameraScrollRate")*dt

            if pX - self.camera.x > LEFTSCROLLBORDER then
                self.camera.x = pX - LEFTSCROLLBORDER
            end
        end

        -- Vertical
        local pY = self.target.y + self.target.height/2
        local pYr = pY - self.camera.y

        if pYr > DOWNSCROLLBORDER then
            self.camera.y = self.camera.y + VAR("cameraScrollRate")*dt

            if pY - self.camera.y < DOWNSCROLLBORDER then
                self.camera.y = pY - DOWNSCROLLBORDER
            end
        end

        -- Only scroll up in flight mode
        if self.target.flying or self.camera.y < self.level:getYEnd()*16-CAMERAHEIGHT then -- ?
            if pYr < UPSCROLLBORDER then
                self.camera.y = self.camera.y - VAR("cameraScrollRate")*dt

                if pY - self.camera.y > UPSCROLLBORDER then
                    self.camera.y = pY - UPSCROLLBORDER
                end
            end
        end

        -- -- And clamp it to level boundaries
        self.camera.x = math.min(self.camera.x, self.level:getXEnd()*16-self.camera.w/2)
        self.camera.x = math.max(self.camera.x, (self.level:getXStart()-1)*16+self.camera.w/2)

        self.camera.y = math.min(self.camera.y, self.level:getYEnd()*16-self.camera.h/2)
        self.camera.y = math.max(self.camera.y, (self.level:getYStart()-1)*16+self.camera.h/2)
    end
end

return Viewport
