Selection = class("Selection")

local borderImg = love.graphics.newImage("img/editor/selection-border.png")
borderImg:setWrap("repeat")


function Selection:initialize(editor, tiles)
    self.editor = editor
    self.level = self.editor.level
    
    self.tiles = tiles or {}
    self.borders = {}
    self.borderTimer = 0
    self.offset = {0, 0}
    self.totalOffset = {0, 0}
    self.quad = love.graphics.newQuad(0, 0, 16, 1, 4, 1)
    
    
    self:updateCache()
end

function Selection:update(dt)
    self.borderTimer = self.borderTimer + dt*8
    
    while self.borderTimer >= 4 do
        self.borderTimer = self.borderTimer - 4
    end
    
    self.quad:setViewport(math.floor(self.borderTimer), 0, 16, 1)
    
    if self.dragging then
        local x, y = self.level:mouseToWorld()
        
        self.offset[1] = math.round((x-self.draggingStart[1])/16)
        self.offset[2] = math.round((y-self.draggingStart[2])/16)
    end
end

function Selection:draw()
    if self.floating then
        for x = 1, self.width do
            for y = 1, self.height do
                local tile = self.floatMap[x][y]
                
                if tile then
                    worldX, worldY = self.level:mapToWorld(x+self.box[1]+self.offset[1]-2, y+self.box[2]+self.offset[2]-2)
                    tile:draw(worldX, worldY)
                end
            end
        end
    end
    
    local scaleY = 1
    
    if self.floating then
        scaleY = 2
    end
    
    for _, v in ipairs(self.borders) do
        love.graphics.draw(borderImg, self.quad, v[1]+(self.totalOffset[1]+self.offset[1])*16, v[2]+(self.totalOffset[2]+self.offset[2])*16, v[3], 1, scaleY)
    end
end

function Selection:replace(tiles)
    self.tiles = tiles
    self:updateCache()
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
    self:updateCache()
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
    
    self:updateCache()
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
    
    self.tiles = tiles
    
    self:updateCache()
end

function Selection:updateCache()
    self.borders = {}
    local SBL = {} -- selectionBordersLookup
    
    self.box = {math.huge, math.huge, 0, 0}
    
    for _, v in ipairs(self.tiles) do
        -- width and height stuff
        if v[1] < self.box[1] then
            self.box[1] = v[1]
        end
        
        if v[2] < self.box[2] then
            self.box[2] = v[2]
        end
        
        if v[1] > self.box[3] then
            self.box[3] = v[1]
        end
        
        if v[2] > self.box[4] then
            self.box[4] = v[2]
        end
        
        self.width = self.box[3]-self.box[1]+1
        self.height = self.box[4]-self.box[2]+1
        
        local x, y = v[1], v[2]
        
        if SBL[x-1] and SBL[x-1][y] and SBL[x-1][y].right then
            SBL[x-1][y].right = false
        end
        if SBL[x+1] and SBL[x+1][y] and SBL[x+1][y].left then
            SBL[x+1][y].left = false
        end
        if SBL[x] and SBL[x][y-1] and SBL[x][y-1].bottom then
            SBL[x][y-1].bottom = false
        end
        if SBL[x] and SBL[x][y+1] and SBL[x][y+1].top then
            SBL[x][y+1].top = false
        end
        
        if not SBL[x] then
            SBL[x] = {}
        end
        
        SBL[x][y] = {
            top = true,
            left = true,
            right = true,
            bottom = true
        }
        
        if SBL[x-1] and SBL[x-1][y] then
            SBL[x][y].left = false
        end
        if SBL[x+1] and SBL[x+1][y] then
            SBL[x][y].right = false
        end
        if SBL[x] and SBL[x][y-1] then
            SBL[x][y].top = false
        end
        if SBL[x] and SBL[x][y+1] then
            SBL[x][y].bottom = false
        end
    end
    
    for _, v in ipairs(self.tiles) do
        local x, y = v[1], v[2]
        local wx, wy = self.level:mapToWorld(x-1, y-1)
        
        if SBL[x][y].top then
            table.insert(self.borders, {wx, wy, 0})
        end
        
        if SBL[x][y].right then
            table.insert(self.borders, {wx+16, wy, math.pi*.5})
        end
        
        if SBL[x][y].bottom then
            table.insert(self.borders, {wx+16, wy+16, math.pi})
        end
        
        if SBL[x][y].left then
            table.insert(self.borders, {wx, wy+16, -math.pi*.5})
        end
    end
end

function Selection:float()
    self.floating = true
    
    self.floatMap = {}
        
    for x = 1, self.level.width do
        self.floatMap[x] = {}
    end

    for _, v in ipairs(self.tiles) do
        local x, y = v[1], v[2]
        self.floatMap[x-self.box[1]+1][y-self.box[2]+1] = self.level.map[x][y]
        self.level:setMap(x, y, nil)
    end
end

function Selection:unFloat()
    self.floating = false
        
    local xl, xr, yt, yb = 1, self.level.width, 1, self.level.height
    
    for i, v in ipairs(self.tiles) do
        self.tiles[i][1] = self.tiles[i][1]+self.totalOffset[1]
        self.tiles[i][2] = self.tiles[i][2]+self.totalOffset[2]
        
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
    
    if xl < 1 or yt < 1 then
        self.level:expandMapTo(xl, yt)
        self.box[1] = self.box[1] - xl + 1
        self.box[2] = self.box[2] - yt + 1
        
        
        for i, v in ipairs(self.tiles) do
            self.tiles[i][1] = self.tiles[i][1]-xl+1
            self.tiles[i][2] = self.tiles[i][2]-yt+1
        end
    end
    
    if xr > self.level.width or yb > self.level.height then
        self.level:expandMapTo(xr, yb)
    end
    
    for x = 1, self.width do
        for y = 1, self.height do
            if self.floatMap[x][y] then
                self.level:setMap(x+self.box[1]-1, y+self.box[2]-1, self.floatMap[x][y])
            end
        end
    end
    
    self.totalOffset = {0, 0}
    
    self:updateCache()
end

function Selection:collision(x, y)
    local drag = false
    
    local mapX, mapY = self.editor.level:mouseToMap()
    
    for _, v in ipairs(self.tiles) do
        if mapX-self.totalOffset[1] == v[1] and mapY-self.totalOffset[2] == v[2] then
            return true
        end
    end
end

function Selection:startDrag(x, y)
    if not self.floating then
        self.editor:floatSelection()
    end
    self.dragging = true
    self.draggingStart = {x, y}
end

function Selection:mousereleased(x, y, button)
    self.dragging = false
    
    if self.offset[1] ~= 0 or self.offset[2] ~= 0 then
        self.box[1] = self.box[1] + self.offset[1]
        self.box[2] = self.box[2] + self.offset[2]
        self.box[3] = self.box[3] + self.offset[1]
        self.box[4] = self.box[4] + self.offset[2]
        
        self.totalOffset[1] = self.totalOffset[1] + self.offset[1]
        self.totalOffset[2] = self.totalOffset[2] + self.offset[2]
        
        self.offset = {0, 0}
        
        self.editor:saveState()
    end
end

function Selection:delete()
    if self.floating then
        return true
    else
        for _, v in ipairs(self.tiles) do
            self.level:setMap(v[1], v[2], nil)
        end
    end
end