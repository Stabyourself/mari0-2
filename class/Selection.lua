Selection = class("Selection")

local borderImg = love.graphics.newImage("img/editor/selection-border.png")
borderImg:setWrap("repeat")

function Selection:initialize(editor, tiles)
    self.editor = editor
    self.level = self.editor.level
    
    self.tiles = tiles or {}
    self.borders = {}
    self.borderTimer = 0
    self.quad = love.graphics.newQuad(0, 0, 16, 1, 4, 1)
    
    self:updateBorders()
end

function Selection:update(dt)
    self.borderTimer = self.borderTimer + dt*8
    
    while self.borderTimer >= 4 do
        self.borderTimer = self.borderTimer - 4
    end
    
    self.quad:setViewport(math.floor(self.borderTimer), 0, 16, 1)
end

function Selection:draw()
    for _, border in ipairs(self.borders) do
        love.graphics.draw(borderImg, self.quad, border[1], border[2], border[3])
    end
end

function Selection:replace(tiles)
    self.tiles = tiles
    self:updateBorders()
end

function Selection:add(bTiles)
    for _, bTile in ipairs(bTiles) do
        local found = false
        
        for _, aTile in ipairs(self.tiles) do
            if aTile[1] == bTile[1] and aTile[2] == bTile[2] then
                found = true
                break
            end
        end
        print(found)
        if not found then
            table.insert(self.tiles, bTile)
        end
    end
    self:updateBorders()
end
    
function Selection:subtract(bTiles)
    local toDelete = {}
    
    for i, aTile in ipairs(self.tiles) do
        local found = false
        
        for _, bTile in ipairs(bTiles) do
            if bTile[1] == aTile[1] and bTile[2] == aTile[2] then
                found = true
                break
            end
        end
        
        if found then
            table.insert(toDelete, i)
        end
    end
    
    for i = #toDelete, 1, -1 do
        table.remove(self.tiles, toDelete[i])
    end
    
    self:updateBorders()
end

function Selection:intersect(bTiles)
    local newSelection = {}
    
    for _, bTile in ipairs(bTiles) do
        local found = false
        
        for _, aTile in ipairs(self.tiles) do
            if bTile[1] == aTile[1] and bTile[2] == aTile[2] then
                found = true
                break
            end
        end
        
        if found then
            table.insert(newSelection, bTile)
        end
    end
    
    self.tiles = newSelection
    
    self:updateBorders()
end

function Selection:updateBorders()
    self.borders = getTileBorders(self.tiles)
end

function Selection:getFloatingSelection()
    return FloatingSelection.fromSelection(self.editor, self)
end

function Selection:collision(x, y)
    local mapX, mapY = self.level:cameraToMap(x, y)

    if self.level:inMap(mapX, mapY) then
        local tile = self.level:getTile(mapX, mapY)

        if tile then
            for _, tile in ipairs(self.tiles) do
                if mapX == tile[1] and mapY == tile[2] then
                    return true
                end
            end
        end
    end
end

function Selection:startDrag(x, y)
    self.dragging = true
    self.draggingStart = {x, y}
end

function Selection:mousereleased(x, y, button)
    self.dragging = false
end

function Selection:delete()
    for _, tile in ipairs(self.tiles) do
        self.level:setMap(tile[1], tile[2], nil)
    end
end

function Selection:getStampMap()
    return StampMap.fromSelection(self.editor, self)
end
