UI = class("UI")

local boxQuad = {}
local boxQuadSize = 8


function UI:initialize(img)
    self.img = love.graphics.newImage(img)
    self.img:setWrap("repeat", "repeat")
    
    self.boxQuad = {}
    
    for y = 1, 3 do
        for x = 1, 3 do
            self.boxQuad[x+(y-1)*3] = love.graphics.newQuad((x-1)*boxQuadSize, (y-1)*boxQuadSize, boxQuadSize, boxQuadSize, self.img:getWidth(), self.img:getHeight())
        end
    end
end

function UI:box(x, y, w, h)
    love.graphics.setColor(156, 252, 240)
    love.graphics.rectangle("fill", x, y, w, h)
    
    love.graphics.setColor(255, 255, 255)
    -- topleft
    love.graphics.draw(self.img, self.boxQuad[1], x-boxQuadSize, y-boxQuadSize)
    
    -- top
    for dx = x, x+w-boxQuadSize, boxQuadSize do
        love.graphics.draw(self.img, self.boxQuad[2], dx, y-boxQuadSize)
    end
    love.graphics.draw(self.img, self.boxQuad[2], x+w-boxQuadSize, y-boxQuadSize)
    
    -- topright
    love.graphics.draw(self.img, self.boxQuad[3], x+w, y-boxQuadSize)
    
    -- left
    for dy = y, y+h-boxQuadSize, boxQuadSize do
        love.graphics.draw(self.img, self.boxQuad[4], x-boxQuadSize, dy)
    end
    love.graphics.draw(self.img, self.boxQuad[4], x-boxQuadSize, y+h-boxQuadSize)
    
    -- middle??
    
    --right
    for dy = y, y+h-boxQuadSize, boxQuadSize do
        love.graphics.draw(self.img, self.boxQuad[6], x+w, dy)
    end
    love.graphics.draw(self.img, self.boxQuad[6], x+w, y+h-boxQuadSize)
    
    -- bottomleft
    love.graphics.draw(self.img, self.boxQuad[7], x-boxQuadSize, y+h)
    
    -- bottom
    for dx = x, x+w-boxQuadSize, boxQuadSize do
        love.graphics.draw(self.img, self.boxQuad[8], dx, y+h)
    end
    love.graphics.draw(self.img, self.boxQuad[8], x+w-boxQuadSize, y+h)
    
    -- bottomright
    love.graphics.draw(self.img, self.boxQuad[9], x+w, y+h)
end