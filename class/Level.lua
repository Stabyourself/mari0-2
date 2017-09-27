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
            if self.tileMap.tiles[self.map[x][y]] then
                if self.tileMap.tiles[self.map[x][y]].collision then
                    self.blocks[x][y] = Block:new(self.world, x-1, y-1)
                end
            end
        end
    end
end

function Level:update(dt)
    self.world:update(dt)
end

function Level:draw(camera)
    local xStart = math.floor(camera.x)+1
    local yStart = math.floor(camera.y)+1
    local xEnd = xStart + WIDTH
    local yEnd = yStart + HEIGHT
    
    print(xStart, xEnd)
    
    for x = xStart, xEnd do
        for y = yStart, yEnd do
            if self:inMap(x, y) then
                local tile = self.tileMap.tiles[self.map[x][y]]
                if tile then
                    tile:draw((x-1)*16, (y-1)*16)
                end
            end
        end
    end

    if PHYSICSDEBUG then
        self.world:draw()
    end
end

function Level:inMap(x, y)
    return x > 0 and x <= self.width and y > 0 and y <= self.height
end