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
            -- [[local Tile = self.world.world:getTile(x, y)
            if Tile and not Tile.invisible and Tile.t ~= "coinblock" then -- Don't prerender coin type blocks because I need to animate them anyway
                Tile:draw(x-xStart+OFFSCREENDRAW, y-1)
            end
            --]]

            local Tile = self.world:getTile(x, y)
            if Tile and not Tile.invisible and Tile.t ~= "coinblock" then
                Tile:draw((x-xStart+OFFSCREENDRAW)*16, (y-1)*16)
            end
        end
    end
    
    love.graphics.setCanvas()
end