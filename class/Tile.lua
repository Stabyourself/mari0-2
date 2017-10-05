
Tile = class("Tile")

Tile.quad = {}
for i = 1, 5 do
    Tile.quad[i] = love.graphics.newQuad((i-1)*TILESIZE, 0, TILESIZE, TILESIZE, TILESIZE*5, TILESIZE)
end

function Tile:initialize(t, img, x, y, collisionImg, collisionImgData, quad, properties)
    self.t = t
    self.x = x
    self.y = y

    if self.t == "regular" then
        self.quad = quad
    elseif self.t == "coinblock" then
        properties = quad
    end
    
    for i, v in pairs(properties) do
        self[i] = v
    end
    
    self.img = img
    
    self.collisionImg = collisionImg
    self.collisionImgData = collisionImgData

    self.depth = self.depth or 0
end

function Tile:draw(x, y)
    if not self.invisible then
        love.graphics.setDepth(DEPTHMUL*self.depth)
        
        if self.t == "regular" then
            love.graphics.draw(self.img, self.quad, x, y)
        elseif self.t == "coinblock" then
            love.graphics.draw(self.img, self.quad[game.coinFrame or 1], x, y)
        end
    end
end