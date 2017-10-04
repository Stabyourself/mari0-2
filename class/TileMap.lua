TileMap = class("TileMap")

function TileMap:initialize(path)
    self.path = path
    self.img = love.graphics.newImage(self.path .. "/tiles.png")
    self.json = JSON:decode(love.filesystem.read(self.path .. "/props.json"))

    self.tiles = {}
    
    local xW = self.img:getWidth()/(TILESIZE+1)

    for y = 1, self.img:getHeight()/(TILESIZE+1) do
        for x = 1, xW do
            local num = x + xW*(y-1)
            local json = self.json.tiles[num]

            if json and json.globalanimated then
                local img = love.graphics.newImage(json.img)

                table.insert(self.tiles, Tile:new("coinblock", json.img, json or {}))
            else
                local quad = love.graphics.newQuad((x-1)*(TILESIZE+1), (y-1)*(TILESIZE+1), TILESIZE, TILESIZE, self.img:getWidth(), self.img:getHeight())
                
                table.insert(self.tiles, Tile:new("regular", self.img, quad, json or {}))
            end
        end
    end
end