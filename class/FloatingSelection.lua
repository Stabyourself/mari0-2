FloatingSelection = class("FloatingSelection")

function FloatingSelection:initialize(editor, tiles)
    self.editor = editor
    self.level = self.editor.level

    self:fromTiles(tiles)
end

function FloatingSelection:fromTiles(tiles)
    self.floatMap = {}
        
    for x = 1, self.level.width do
        self.floatMap[x] = {}
    end

    for _, v in ipairs(tiles) do
        local x, y = v[1], v[2]
        self.floatMap[x-self.box[1]+1][y-self.box[2]+1] = self.level.map[x][y]
        self.level:setMap(x, y, nil)
    end
end

function FloatingSelection:update(dt)

end

function FloatingSelection:draw()
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
        love.graphics.draw(borderImg, self.quad, v[1]+(self.totalOffset[1]+self.offset[1])*16, v[2]+(self.totalOffset[2]+self.offset[2])*16, v[3])
    end
end

function Selection:updateCache()
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
    end
end

function FloatingSelection:mousereleased(x, y, button)
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

function FloatingSelection:unFloat()
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