local Gui3 = ...
Gui3.TileGrid = class("Gui3.TileGrid", Gui3.Element)

Gui3.TileGrid.perRow = 8
Gui3.TileGrid.size = {16, 16}
Gui3.TileGrid.gutter = {1, 1}

function Gui3.TileGrid:initialize(x, y, tileMap, func)
    self.tileMap = tileMap
    self.tiles = tileMap.tiles
    self.func = func

    Gui3.Element.initialize(self, x, y, 0, 0)

    self:updateSize()

    self.selected = nil
end

function Gui3.TileGrid:update(dt, absX, absY)
    Gui3.Element.update(self, dt, absX, absY)

    local maxWidth = self.parent:getInnerWidth()

    self.perRow = math.max(1, math.floor((maxWidth-self.x)/(self.size[1]+self.gutter[1])))

    self:updateSize()
end

function Gui3.TileGrid:updateSize()
    self.w = self.perRow*(self.size[1]+self.gutter[1])-self.gutter[1]
    self.h = math.ceil(#self.tiles/self.perRow)*(self.size[2]+self.gutter[2])
end

function Gui3.TileGrid:getCollision(x, y)
    local tileX = math.floor(x/(self.size[1]+self.gutter[1]))+1
    local tileY = math.floor(y/(self.size[2]+self.gutter[2]))+1

    if tileX < 1 or tileX > self.perRow then
        return false
    end

    local tileNum = (tileY-1)*self.perRow+tileX

    if tileNum < 1 or tileNum > #self.tiles then
        return false
    else
        return tileNum
    end
end

function Gui3.TileGrid:draw(level)
    local mouseTile
    if self.mouse[1] then
        mouseTile = self:getCollision(self.mouse[1], self.mouse[2])
    end

    local topY = math.ceil((self.parent.scroll[2]-self.y)/(self.size[2]+self.gutter[2]))
    local bottomY = math.ceil((self.parent.scroll[2]-self.y)/(self.size[2]+self.gutter[2]) + (self.parent:getInnerHeight())/(self.size[2]+self.gutter[2]))

    for tileY = topY, bottomY do
        for tileX = 1, self.perRow do
            local tileNum = (tileY-1)*self.perRow+tileX

            if self.tiles[tileNum] then
                local x = (tileX-1)*(self.size[1] + self.gutter[1])
                local y = (tileY-1)*(self.size[2] + self.gutter[2])

                self.tiles[tileNum]:draw(x, y)

                if tileNum == mouseTile then
                    love.graphics.setColor(1, 1, 1, 0.7)
                    love.graphics.rectangle("fill", x, y, self.size[1], self.size[2])
                    love.graphics.setColor(1, 1, 1, 1)
                end
            end
        end
    end

    if self.selected then
        local tileX = (self.selected-1)%self.perRow+1
        local tileY = math.ceil(self.selected/self.perRow)-1

        local x = (tileX-1)*(self.size[1] + self.gutter[1])
        local y = tileY*(self.size[2] + self.gutter[2])

        Gui3.drawBox(self.gui.img.box, Gui3.boxQuad, x-2, y-3, 20, 22)
    end

    Gui3.Element.draw(self, level)
end

function Gui3.TileGrid:mousepressed(x, y, button)
    local col = self:getCollision(x, y)

    if col then
        self.func(self, col)
    end

    return Gui3.Element.mousepressed(self, x, y, button)
end
