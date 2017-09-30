LevelCanvas = class("LevelCanvas")

function LevelCanvas:initialize(level)
    self.level = level
    self.center = 0
    self.canvas = love.graphics.newCanvas(LEVELCANVASWIDTH*TILESIZE, HEIGHT*TILESIZE)
end

function LevelCanvas:update(dt)
    love.graphics.setCanvas(self.canvas)
    while self.currentBlock < #self.drawList do
        self:drawBlock()
    end
    love.graphics.setCanvas()
end

function LevelCanvas:drawBlock()
    local v = self.drawList[self.currentBlock]
    
    v.tile:draw((v.x-1)*16, (v.y-1)*16)

    self.currentBlock = self.currentBlock + 1
end

function LevelCanvas:startJob(center)
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()
    love.graphics.setCanvas()

    self.currentBlock = 1
    self.center = center
    
    local xStart = self.center-LEVELCANVASWIDTH/2
    xStart = math.clamp(xStart, 1, self.level.width-LEVELCANVASWIDTH+1)
    local xEnd = xStart+LEVELCANVASWIDTH
    xEnd = math.min(self.level.width, xEnd)

    local yStart = 1
    local yEnd = HEIGHT
    
    self.drawList = {}
    
    for x = xStart, xEnd do
        for y = yStart, yEnd do
            local tile = self.level.tileMap.tiles[self.level.background[x][y]]
            if tile and not tile.invisible then
                table.insert(self.drawList, {
                    x = x,
                    y = y,
                    tile = tile
                })
            end

            local tile = self.level.tileMap.tiles[self.level.map[x][y]]
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