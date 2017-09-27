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

function Level:update(dt, camera)
    self.world:update(dt)
end

function Level:draw(camera)
    for _, v in ipairs(self.drawList) do
        v.tile:draw((v.x-1)*16, (v.y-1)*16)
    end
    
    if PHYSICSDEBUG then
        self.world:draw()
    end
end

function Level:checkDrawList(camera)
    if math.floor(camera.x)+1 ~= self.drawListX then
        self:generateDrawList(camera)
    end
end

function Level:generateDrawList(camera)
    local xStart = math.floor(camera.x)+1
    local yStart = math.floor(camera.y)+1
    local xEnd = xStart + WIDTH
    local yEnd = yStart + HEIGHT
    
    local toDraw = {}
    
    self.drawList = {}
    self.drawListX = xStart
    
    for x = xStart, xEnd do
        for y = yStart, yEnd do
            if self:inMap(x, y) then
                local tile = self.tileMap.tiles[self.map[x][y]]
                
                if tile and not tile.invisible then
                    table.insert(self.drawList, {
                        x = x,
                        y = y,
                        tile = tile
                    })
                end
            end
        end
    end
    
    table.sort(self.drawList, function(a, b) return a.tile.depth>b.tile.depth end)
end

function Level:inMap(x, y)
    return x > 0 and x <= self.width and y > 0 and y <= self.height
end

--13.7 ms