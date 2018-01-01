UI = class("UI")

local boxQuad = {}
local boxQuadSize = 8


function UI:initialize(img)
    self.img = love.graphics.newImage(img)
    self.img:setWrap("repeat", "repeat")
    
    self.boxQuad = {}

    self.boxQuad[1] = love.graphics.newQuad(0, 0, 8, 8, self.img:getWidth(), self.img:getHeight())
    self.boxQuad[2] = love.graphics.newQuad(8, 0, 1, 8, self.img:getWidth(), self.img:getHeight())
    self.boxQuad[3] = love.graphics.newQuad(9, 0, 8, 8, self.img:getWidth(), self.img:getHeight())
    self.boxQuad[4] = love.graphics.newQuad(0, 8, 8, 1, self.img:getWidth(), self.img:getHeight())
    
    self.boxQuad[6] = love.graphics.newQuad(9, 8, 8, 1, self.img:getWidth(), self.img:getHeight())
    self.boxQuad[7] = love.graphics.newQuad(0, 9, 8, 8, self.img:getWidth(), self.img:getHeight())
    self.boxQuad[8] = love.graphics.newQuad(8, 9, 1, 8, self.img:getWidth(), self.img:getHeight())
    self.boxQuad[9] = love.graphics.newQuad(9, 9, 8, 8, self.img:getWidth(), self.img:getHeight())
end

function UI:box(x, y, w, h)
    love.graphics.setColor(156, 252, 240)
    love.graphics.rectangle("fill", x, y, w, h)
    
    love.graphics.setColor(255, 255, 255)
    -- topleft
    love.graphics.draw(self.img, self.boxQuad[1], x-boxQuadSize, y-boxQuadSize)
    
    -- top
    love.graphics.draw(self.img, self.boxQuad[2], x, y-boxQuadSize, 0, w, 1)
    
    -- topright
    love.graphics.draw(self.img, self.boxQuad[3], x+w, y-boxQuadSize)
    
    -- left
    love.graphics.draw(self.img, self.boxQuad[4], x-boxQuadSize, y, 0, 1, h)
    
    -- middle??
    
    --right
    love.graphics.draw(self.img, self.boxQuad[6], x+w, y, 0, 1, h)
    
    -- bottomleft
    love.graphics.draw(self.img, self.boxQuad[7], x-boxQuadSize, y+h)
    
    -- bottom
    love.graphics.draw(self.img, self.boxQuad[8], x, y+h, 0, w, 1)
    
    -- bottomright
    love.graphics.draw(self.img, self.boxQuad[9], x+w, y+h)
end