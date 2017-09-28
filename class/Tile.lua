Tile = class("Tile")

function Tile:initialize(img, quad, properties)
    self.img = img
    self.quad = quad
    self.invisible = properties.invisible or false
    self.collision = properties.collision or false
    self.breakable = properties.breakable or false
    self.coinblock = properties.coinblock or false
    self.depth = properties.depth or 0
end

function Tile:draw(x, y)
    if not self.invisible then
        love.graphics.setDepth(DEPTHMUL*self.depth)
        love.graphics.draw(self.img, self.quad, x, y)
    end
end