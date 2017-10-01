LevelCanvas = class("LevelCanvas")

function LevelCanvas:initialize(level, x)
    self.level = level
    self.x = x
    self.canvas = love.graphics.newCanvas(LEVELCANVASWIDTH*TILESIZE, HEIGHT*TILESIZE)
    
    self:render(self.x)
end

function LevelCanvas:render(renderX)
    love.graphics.setCanvas(self.canvas)
    
    local xStart = renderX
    local xEnd = xStart+LEVELCANVASWIDTH-1
    xEnd = math.min(self.level.width, xEnd)

    local yStart = 1
    local yEnd = HEIGHT
    
    self.drawList = {}
    
    for x = xStart, xEnd do
        for y = yStart, yEnd do
            local tile = self.level.tileMap.tiles[self.level.background[x][y]]
            if tile and not tile.invisible then
                tile:draw((x-xStart)*16, (y-1)*16)
            end

            local tile = self.level.tileMap.tiles[self.level.map[x][y]]
            if tile and not tile.invisible then
                tile:draw((x-xStart)*16, (y-1)*16)
            end
        end
    end
    
    love.graphics.setCanvas()
end