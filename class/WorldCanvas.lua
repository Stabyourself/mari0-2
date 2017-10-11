WorldCanvas = class("WorldCanvas")

function WorldCanvas:initialize(world, x)
    self.world = world
    self.x = x
    self.canvas = love.graphics.newCanvas((LEVELCANVASWIDTH+OFFSCREENDRAW*2)*TILESIZE, HEIGHT*TILESIZE)
    
    self:render(self.x)
end

function WorldCanvas:render(renderX)
    love.graphics.setCanvas(self.canvas)
    
    local xStart = renderX
    local xEnd = xStart+LEVELCANVASWIDTH-1
    xEnd = math.min(self.world.width, xEnd)

    local yStart = 1
    local yEnd = HEIGHT
    
    self.drawList = {}
    
    for x = xStart, xEnd do
        for y = yStart, yEnd do
            for i = #self.world.map, 1, -1 do
                local Tile = self.world:getTile(x, y, i)
                if Tile and not Tile.invisible and Tile.type ~= "coinAnimation" then
                    Tile:draw((x-xStart+OFFSCREENDRAW)*self.world.tileMap.tileSize, (y-1)*self.world.tileMap.tileSize)
                end
            end
        end
    end
    
    love.graphics.setCanvas()
end