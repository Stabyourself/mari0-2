TileMap = class("TileMap")

function TileMap:initialize(path)
    self.path = path
    self.img = love.graphics.newImage(self.path .. "/tiles.png")
    self.json = JSON:decode(love.filesystem.read(self.path .. "/props.json"))

    self.tiles = {}

    for x = 0, self.img:getWidth()/TILESIZE-1 do
        local quad = love.graphics.newQuad(x*TILESIZE, 0, TILESIZE, TILESIZE, self.img:getWidth(), self.img:getHeight())
        self.tiles[x] = Tile:new(self.img, quad, self.json.tiles[x+1])
    end
end