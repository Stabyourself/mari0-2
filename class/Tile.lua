Tile = class("Tile")

function Tile:initialize(img, quad, properties)
    self.img = img
    self.quad = quad
    self.invisible = properties.invisible
    self.collision = properties.collision
end

function Tile:draw(x, y)
    if not self.invisible then
        love.graphics.draw(self.img, self.quad, x, y)
    end
end