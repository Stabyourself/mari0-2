FloatingSelection = class("FloatingSelection")

local borderImg = love.graphics.newImage("img/editor/selection-border.png")
borderImg:setWrap("repeat")

function FloatingSelection:initialize(editor, tiles)
    self.editor = editor
    self.level = self.editor.level
    self.tiles = tiles

    self.pos = {0, 0}

    self.borderTimer = 0
    self.quad = love.graphics.newQuad(0, 0, 16, 2, 4, 1)

    self:fromTiles(tiles)

    self:updateBorders()
end

function FloatingSelection:fromTiles(tiles)
    self:updateCache()

    self.floatMap = {}
        
    for x = 1, self.level.width do
        self.floatMap[x] = {}
    end

    for _, v in ipairs(tiles) do
        local x, y = v[1], v[2]
        self.floatMap[x-self.pos[1]+1][y-self.pos[2]+1] = self.level.map[x][y]

        self.level:setMap(x, y, nil)
    end

end

function FloatingSelection:update(dt)
    self.borderTimer = self.borderTimer + dt*8
    
    while self.borderTimer >= 4 do
        self.borderTimer = self.borderTimer - 4
    end
    
    self.quad:setViewport(math.floor(self.borderTimer), 0, 16, 2)
    
    if self.dragging then
        local x, y = self.level:mouseToWorld()
        
        self.pos[1] = self.dragStartPos[1] + math.round((x-self.draggingStart[1])/16)
        self.pos[2] = self.dragStartPos[2] + math.round((y-self.draggingStart[2])/16)
    end

end

function FloatingSelection:draw()
    for x = 1, self.width do
        for y = 1, self.height do
            local tile = self.floatMap[x][y]
            
            if tile then
                worldX, worldY = self.level:mapToWorld(x+self.pos[1]-2, y+self.pos[2]-2)
                tile:draw(worldX, worldY)
            end
        end
    end
    
    local scaleY = 1
    
    if self.floating then
        scaleY = 2
    end

    for _, v in ipairs(self.borders) do
        love.graphics.draw(borderImg, self.quad, v[1]+self.pos[1]*16, v[2]+self.pos[2]*16, v[3])
    end
end

function FloatingSelection:updateCache()
    xl, yt, xr, yb = math.huge, math.huge, 0, 0

    for i, v in ipairs(self.tiles) do
        if self.tiles[i][1] < xl then
            xl = self.tiles[i][1]
        end
        
        if self.tiles[i][1] > xr then
            xr = self.tiles[i][1]
        end
        
        if self.tiles[i][2] < yt then
            yt = self.tiles[i][2]
        end
        
        if self.tiles[i][2] > yb then
            yb = self.tiles[i][2]
        end
    end
    
    self.pos = {xl, yt}

    self.width = xr-xl+1
    self.height = yb-yt+1
end

function FloatingSelection:mousereleased(x, y, button)
    self.dragging = false
    self.editor:saveState()
end

function FloatingSelection:unFloat()
    print_r(self.pos)
    if self.pos[1] < 0 or self.pos[2] < 0 then
        local moveX, moveY = self.level:expandMapTo(self.pos[1], self.pos[2])
        self.pos[1] = self.pos[1] + moveX
        self.pos[2] = self.pos[2] + moveY
    end
    
    if self.pos[1]+self.width-1 > self.level.width or self.pos[2]+self.height-1 > self.level.height then
        self.level:expandMapTo(self.pos[1]+self.width-1, self.pos[2]+self.height-1)
    end
    
    for x = 1, self.width do
        for y = 1, self.height do
            if self.floatMap[x][y] then
                self.level:setMap(self.pos[1]+x-1, self.pos[2]+y-1, self.floatMap[x][y])
            end
        end
    end
    
    self.totalOffset = {0, 0}
    
    --self:updateCache()
end

function FloatingSelection:startDrag(x, y)
    self.dragging = true
    self.draggingStart = {x, y}
    self.dragStartPos = {self.pos[1], self.pos[2]}
end

function FloatingSelection:updateBorders()
    self.borders = getTileBorders(self.tiles, -self.pos[1], -self.pos[2])
end

function FloatingSelection:collision(x, y)
    local mapX, mapY = self.level:cameraToMap(x, y)
    local floatMapX = mapX-self.pos[1]+1
    local floatMapY = mapY-self.pos[2]+1

    if floatMapX < 1 or floatMapX > self.width or floatMapY < 1 or floatMapY > self.height then
        return false
    end

    return self.floatMap[floatMapX][floatMapY]
end

function FloatingSelection:getSelection()
    local tiles = {}

    print_r(self.pos)

    for x = 1, self.width do
        for y = 1, self.height do
            if self.floatMap[x][y] then
                table.insert(tiles, {x+self.pos[1]-1, y+self.pos[2]-1})
            end
        end
    end

    return Selection:new(self.editor, tiles)
end
