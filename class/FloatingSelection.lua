FloatingSelection = class("FloatingSelection")

local borderImg = love.graphics.newImage("img/editor/selection-border.png")
borderImg:setWrap("repeat")

function FloatingSelection.fromSelection(editor, selection)
    local stampMap, xl, yt = StampMap.fromSelection(editor, selection)

    for x = 1, stampMap.width do
        for y = 1, stampMap.height do
            local absX, absY = x+xl-1, y+yt-1
            
            if stampMap.map[x][y] and editor.level:inMap(absX, absY) and editor.level:getTile(absX, absY) then
                editor.level:setMap(absX, absY, nil)
            end
        end
    end
    
    local floatingSelection = FloatingSelection:new(editor, stampMap, {xl, yt})

    return floatingSelection
end

function FloatingSelection:initialize(editor, stampMap, pos)
    self.editor = editor
    self.level = self.editor.level

    self.borderTimer = 0
    self.quad = love.graphics.newQuad(0, 0, 16, 2, 4, 1)
    self.map = stampMap.map
    self.width = stampMap.width
    self.height = stampMap.height
    self.pos = pos

    self:updateBorders()
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
            local tile = self.map[x][y]
            
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
        love.graphics.draw(borderImg, self.quad, v[1]+(self.pos[1]-1)*16, v[2]+(self.pos[2]-1)*16, v[3])
    end
end

function FloatingSelection:mousereleased(x, y, button)
    self.dragging = false
end

function FloatingSelection:unFloat()
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
            if self.map[x][y] then
                self.level:setMap(self.pos[1]+x-1, self.pos[2]+y-1, self.map[x][y])
            end
        end
    end
    
    self.totalOffset = {0, 0}
end

function FloatingSelection:startDrag(x, y)
    self.dragging = true
    self.draggingStart = {x, y}
    self.dragStartPos = {self.pos[1], self.pos[2]}
end

function FloatingSelection:updateBorders()
    local tiles = {}
    
    for x = 1, self.width do
        for y = 1, self.height do
            if self.map[x][y] then
                table.insert(tiles, {x, y})
            end
        end
    end

    self.borders = getTileBorders(tiles)
end

function FloatingSelection:collision(x, y)
    local mapX, mapY = self.level:cameraToMap(x, y)
    local floatMapX = mapX-self.pos[1]+1
    local floatMapY = mapY-self.pos[2]+1

    if floatMapX < 1 or floatMapX > self.width or floatMapY < 1 or floatMapY > self.height then
        return false
    end

    return self.map[floatMapX][floatMapY]
end

function FloatingSelection:getSelection()
    local tiles = {}

    for x = 1, self.width do
        for y = 1, self.height do
            if self.map[x][y] then
                table.insert(tiles, {x+self.pos[1]-1, y+self.pos[2]-1})
            end
        end
    end

    return Selection:new(self.editor, tiles)
end

function FloatingSelection:getStampMap()
    local stampMap = {}

    stampMap.width = self.width
    stampMap.height = self.height
    stampMap.map = {}

    for x = 1, self.width do
        stampMap.map[x] = {}
        
        for y = 1, self.height do
            stampMap.map[x][y] = self.map[x][y]
        end
    end

    return stampMap, self.pos[1], self.pos[2]
end
