
Tile = class("Tile")

Tile.quad = {}
for i = 1, 5 do
    Tile.quad[i] = love.graphics.newQuad((i-1)*TILESIZE, 0, TILESIZE, TILESIZE, TILESIZE*5, TILESIZE)
end

function Tile:initialize(t, img, quad, properties)
    self.t = t

    if self.t == "quad" then
        self.img = img
        self.quad = quad
    elseif self.t == "coin" then
        properties = quad
        self.img = love.graphics.newImage(img)
    end

    self.invisible = properties.invisible or false
    self.collision = properties.collision or false
    self.breakable = properties.breakable or false
    self.coinBlock = properties.coinBlock or false
    self.depth = properties.depth or 0
end

function Tile:draw(x, y)
    if not self.invisible then
        love.graphics.setDepth(DEPTHMUL*self.depth)

        if self.t == "quad" then
            love.graphics.draw(self.img, self.quad, x, y)
        elseif self.t == "coin" then
            love.graphics.draw(self.img, self.quad[game.coinFrame], x, y)
        end
    end
end