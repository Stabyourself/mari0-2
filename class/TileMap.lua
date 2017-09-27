TileMap = class("TileMap")

function TileMap:initialize(path)
    self.path = path
    self.img = love.graphics.newImage(self.path .. "/tiles.png")
    self.json = JSON:decode(love.filesystem.read(self.path .. "/props.json"))

    self.tiles = {}
    
    local xW = self.img:getWidth()/TILESIZE

    for y = 1, self.img:getHeight()/TILESIZE do
        for x = 1, xW do
            local quad = love.graphics.newQuad((x-1)*TILESIZE, (y-1)*TILESIZE, TILESIZE, TILESIZE, self.img:getWidth(), self.img:getHeight())
            local num = x + xW*(y-1)
            
            table.insert(self.tiles, Tile:new(self.img, quad, self.json.tiles[num] or {}))
        end
    end
end