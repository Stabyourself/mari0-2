Level = class("Level")

function Level:initialize(path, tileMap)
    self.json = JSON:decode(love.filesystem.read(path))
    self.tileMap = tileMap

    self.map = self.json.map
    self.width = #self.map
    self.height = #self.map[1]
    
    self.world = World:new()

    self.blocks = {}
    for x = 1, self.width do
        self.blocks[x] = {}

        for y = 1, self.height do
            if not self.tileMap.tiles[self.map[x][y]].invisible then
                self.blocks[x][y] = Block:new(self.world, x-1, y-1)
            end
        end
    end
end

function Level:update(dt)
    self.world:update(dt)
end

function Level:draw()
    for x = 1, WIDTH do
        for y = 1, HEIGHT+1 do
            if self:inMap(x, y) then
                self.tileMap.tiles[self.map[x][y]]:draw((x-1)*16, (y-1)*16)
            end
        end
    end

    self.world:draw()
end

function Level:inMap(x, y)
    return x > 0 and x <= self.width and y > 0 and y <= self.height
end