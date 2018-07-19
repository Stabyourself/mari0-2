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
    self.hoveringTile = nil
end

function Gui3.TileGrid:mousemoved(x, y)
    Gui3.Element.mousemoved(self, x, y)

    self:setHoveringTile(self:getCollision(self.mouse[1], self.mouse[2]))
end

function Gui3.TileGrid:parentScrollChanged()
    self:updateRender()
end

function Gui3.TileGrid:parentSizeChanged()
    local maxWidth = self.parent:getInnerWidth()
    local newPerRow = math.max(1, math.floor((maxWidth-self.x)/(self.size[1]+self.gutter[1])))

    if newPerRow ~= self.perRow then
        self.perRow = newPerRow
        self:updateSize()
    end
end

function Gui3.TileGrid:setHoveringTile(hoveringTile)
    if hoveringTile ~= self.hoveringTile then
        self.hoveringTile = hoveringTile
        self:updateRender()
    end
end

function Gui3.TileGrid:updateSize()
    self.w = self.perRow*(self.size[1]+self.gutter[1])-self.gutter[1]
    self.h = math.ceil(#self.tiles/self.perRow)*(self.size[2]+self.gutter[2])

    self:sizeChanged()
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

function Gui3.TileGrid:draw()
    local topY = math.ceil((self.parent.scroll[2]-self.y)/(self.size[2]+self.gutter[2]))
    local bottomY = math.ceil((self.parent.scroll[2]-self.y)/(self.size[2]+self.gutter[2]) + (self.parent:getInnerHeight())/(self.size[2]+self.gutter[2]))

    for tileY = topY, bottomY do
        for tileX = 1, self.perRow do
            local tileNum = (tileY-1)*self.perRow+tileX

            if self.tiles[tileNum] then
                local x = (tileX-1)*(self.size[1] + self.gutter[1])
                local y = (tileY-1)*(self.size[2] + self.gutter[2])

                self.tiles[tileNum]:draw(x, y)

                if tileNum == self.hoveringTile then
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

    Gui3.Element.draw(self)
end

function Gui3.TileGrid:setSelected(i)
    self.selected = i
    self:updateRender()
end

function Gui3.TileGrid:mousepressed(x, y, button)
    local col = self:getCollision(x, y)

    if col then
        self.func(self, col)
    end

    Gui3.Element.mousepressed(self, x, y, button)
end

function Gui3.TileGrid:mouseleft()
    Gui3.Element.mouseleft(self)

    self:setHoveringTile(false)
end
