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
    for _, v in ipairs(self.borders) do
        love.graphics.draw(borderImg, self.quad, v[1], v[2], v[3])
    end
end

function Selection:replace(tiles)
    self.tiles = tiles
    self:updateBorders()
end

function Selection:add(tiles)
    for _, v in ipairs(tiles) do
        local found = false
        
        for _, w in ipairs(self.tiles) do
            if w[1] == v[1] and w[2] == v[2] then
                found = true
                break
            end
        end
        
        if not found then
            table.insert(self.tiles, v)
        end
    end
    self:updateBorders()
end
    
function Selection:subtract(tiles)
    local toDelete = {}
    
    for i, v in ipairs(self.tiles) do
        local found = false
        
        for _, w in ipairs(tiles) do
            if w[1] == v[1] and w[2] == v[2] then
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

function Selection:intersect(tiles)
    local newSelection = {}
    
    for _, v in ipairs(tiles) do
        local found = false
        
        for _, w in ipairs(self.tiles) do
            if w[1] == v[1] and w[2] == v[2] then
                found = true
                break
            end
        end
        
        if found then
            table.insert(newSelection, v)
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
            for _, v in ipairs(self.tiles) do
                if mapX == v[1] and mapY == v[2] then
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
    for _, v in ipairs(self.tiles) do
        self.level:setMap(v[1], v[2], nil)
    end
end

function Selection:getStampMap()
    return StampMap.fromSelection(self.editor, self)
end
