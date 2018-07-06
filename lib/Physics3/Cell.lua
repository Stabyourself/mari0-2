local Cell = class("Physics3.Cell")

function Cell:initialize(tile)
    self.tile = tile
    self.coin = false
end

function Cell:draw(x, y)
    if self.tile then
        self.tile:draw(x, y)
    end

    if self.coin then
        game.mappack.coinTile:draw(x, y)
    end
end

return Cell
