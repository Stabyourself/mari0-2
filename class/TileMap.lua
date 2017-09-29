TileMap = class("TileMap")

function TileMap:initialize(path)
    self.path = path
    self.img = love.graphics.newImage(self.path .. "/tiles.png")
    self.json = JSON:decode(love.filesystem.read(self.path .. "/props.json"))

    self.tiles = {}
    
    local xW = self.img:getWidth()/TILESIZE

    for y = 1, self.img:getHeight()/TILESIZE do
        for x = 1, xW do
            local num = x + xW*(y-1)
            local json = self.json.tiles[num]

            if json and json.globalanimated then
                local img = love.graphics.newImage(json.img)

                table.insert(self.tiles, Tile:new("coin", json.img, json or {}))
            else
                local quad = love.graphics.newQuad((x-1)*TILESIZE, (y-1)*TILESIZE, TILESIZE, TILESIZE, self.img:getWidth(), self.img:getHeight())
                
                table.insert(self.tiles, Tile:new("quad", self.img, quad, json or {}))
            end
        end
    end
end