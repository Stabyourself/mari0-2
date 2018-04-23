local Stamp = class("Editor.Stamp")

function Stamp:initialize(editor)
    self.editor = editor
    self.level = self.editor.level

    self.stampMap = self.editor.tileMap.stampMaps[2]
    self.dragging = false
end

function Stamp:draw()
    if self.stampMap then
        local mouseX, mouseY = self.level:getMouse()
        local offset = {self:getOffset()}
        local worldX, worldY = self.level:cameraToWorld(mouseX, mouseY)
        
        if self.stampMap.type == "simple" then
            worldX = worldX+offset[1]*16
            worldY = worldY+offset[2]*16
            local coordX, coordY = self.level:worldToCoordinate(worldX, worldY)

            for x = 1, self.stampMap.width do
                for y = 1, self.stampMap.height do
                    local tileX = (coordX+x-1)*16
                    local tileY = (coordY+y-1)*16
                    
                    local tile = self.stampMap.map[x] and self.stampMap.map[x][y]

                    if tile then
                        tile:draw(tileX, tileY, true)
                    end
                end
            end
            
        elseif self.stampMap.type == "quads" then
            local coordX, coordY = self.level:worldToCoordinate(worldX, worldY)
            
            if self.dragging then
                local startX, startY = self.dragStart[1], self.dragStart[2]
                local w, h = coordX-startX+1, coordY-startY+1
                
                if w < 1 then
                    startX = startX + w-1
                    w = -w+2
                end
                
                if h < 1 then
                    startY = startY + h-1
                    h = -h+2
                end
                
                local quadStampMap = self:getQuadStampMap(w, h)
                
                for x = 1, w do
                    for y = 1, h do
                        quadStampMap[x][y]:draw((startX+x-2)*16, (startY+y-2)*16, true)
                    end
                end
                
            else
                local tileX, tileY = self.level:coordinateToWorld(coordX-1, coordY-1)
                self.stampMap.map[1][1]:draw(tileX, tileY, true)
            end
        end
    end
end

function Stamp:mousepressed(x, y, button)
    if button == 1 then
        self.dragging = true
        
        local coordX, coordY = self.level:cameraToCoordinate(x, y)
        
        self.dragStart = {coordX, coordY}
    end
end

function Stamp:mousereleased(x, y, button)
    if self.stampMap and button == 1 and self.dragging then
        if self.stampMap.type == "simple" then
            local offset = {self:getOffset()}
            local worldX, worldY = self.level:cameraToWorld(x, y)
            worldX = worldX+offset[1]*16
            worldY = worldY+offset[2]*16
            local coordX, coordY = self.level:worldToCoordinate(worldX, worldY)
            
            self:stamp(coordX, coordY)
        
        elseif self.stampMap.type == "quads" then
            local coordX, coordY = self.level:cameraToCoordinate(x, y)
            
            self:quadStamp(self.dragStart[1], self.dragStart[2], coordX-self.dragStart[1]+1, coordY-self.dragStart[2]+1)
        end
        
        self.dragging = false
    end
end

function Stamp:stamp(coordX, coordY)
    for x = 1, self.stampMap.width do
        for y = 1, self.stampMap.height do
            self.level:setCoordinate(coordX+x, coordY+y, self.stampMap.map[x][y])
        end
    end

    self.editor:saveState()
end

function Stamp:getQuadStampMap(w, h)
    local paddings = self.stampMap.paddings
    
    local map = {}
    
    for i = 1, w do
        map[i] = {}
    end
    
    local middleXnum = #self.stampMap.map-paddings[2]-paddings[4]
    local middleYnum = #self.stampMap.map[1]-paddings[1]-paddings[3]
    
    -- Bottom right
    for lx = math.max(1, w-paddings[2]+1), w do
        for ly = h-paddings[3]+1, h do
            local offsetX = (lx-w-1)%paddings[2]
            local offsetY = (ly-h-1)%paddings[3]
            
            map[lx][ly] = self.stampMap.map[1+self.stampMap.width-paddings[2]+offsetX][1+self.stampMap.height-paddings[3]+offsetY]
        end
    end
    
    -- Bottom
    for lx = 1+paddings[4], w-paddings[2] do
        for ly = h-paddings[3]+1, h do
            local offsetX = lx%middleXnum
            local offsetY = (ly-h-1)%paddings[3]
            
            map[lx][ly] = self.stampMap.map[1+paddings[4]+offsetX][1+self.stampMap.height-paddings[3]+offsetY]
        end
    end
    
    -- Bottom left
    for lx = 1, math.min(w, paddings[4]) do
        for ly = h-paddings[3]+1, h do
            local offsetX = (lx-1)%paddings[4]
            local offsetY = (ly-h-1)%paddings[3]
            
            map[lx][ly] = self.stampMap.map[1+offsetX][1+self.stampMap.height-paddings[3]+offsetY]
        end
    end
    
    -- Right
    for lx = math.max(1, w-paddings[2]+1), w do
        for ly = 1+paddings[1], h-paddings[3] do
            local offsetX = (lx-w-1)%paddings[2]
            local offsetY = ly%middleYnum
            
            map[lx][ly] = self.stampMap.map[1+self.stampMap.width-paddings[2]+offsetX][1+paddings[1]+offsetY]
        end
    end
    
    -- Center
    for lx = paddings[4]+1, w-paddings[2] do
        for ly = 1+paddings[1], h-paddings[3] do
            local offsetX = lx%middleXnum
            local offsetY = ly%middleYnum
            
            map[lx][ly] = self.stampMap.map[1+paddings[4]+offsetX][1+paddings[1]+offsetY]
        end
    end
    
    -- Left
    for lx = 1, math.min(w, paddings[4]) do
        for ly = 1+paddings[1], h-paddings[3] do
            local offsetX = (lx-1)%paddings[4]
            local offsetY = ly%middleYnum
            
            map[lx][ly] = self.stampMap.map[1+offsetX][1+paddings[1]+offsetY]
        end
    end
    
    -- Top right
    for lx = math.max(1, w-paddings[2]+1), w do
        for ly = 1, paddings[1] do
            local offsetX = (lx-w-1)%paddings[2]
            local offsetY = (ly-1)%paddings[1]
            
            map[lx][ly] = self.stampMap.map[1+self.stampMap.width-paddings[2]+offsetX][1+offsetY]
        end
    end
    
    -- Top
    for lx = 1+paddings[4], w-paddings[2] do
        for ly = 1, paddings[1] do
            local offsetX = lx%middleXnum
            local offsetY = (ly-1)%paddings[1]
            
            map[lx][ly] = self.stampMap.map[1+paddings[4]+offsetX][1+offsetY]
        end
    end
    
    -- Top left
    for lx = 1, math.min(w, paddings[4]) do
        for ly = 1, paddings[1] do
            local offsetX = (lx-1)%paddings[4]
            local offsetY = (ly-1)%paddings[1]
            
            map[lx][ly] = self.stampMap.map[1+offsetX][1+offsetY]
        end
    end
    
    return map
end
    
function Stamp:quadStamp(x, y, w, h)
    if w < 1 then
        x = x + w-1
        w = -w+2
    end
    
    if h < 1 then
        y = y + h-1
        h = -h+2
    end
    
    local quadStampMap = self:getQuadStampMap(w, h)

    -- expand the layer as necessary
    local layer = self.editor.activeLayer
    layer:expandTo(x, y)
    layer:expandTo(x+w-1, y+h-1)

    for lx = 1, w do
        for ly = 1, h do
            layer:setCoordinate(x+lx-1, y+ly-1, quadStampMap[lx][ly])
        end
    end
    
    self.editor:saveState()
end

function Stamp:getOffset()
    return -self.stampMap.width/2-.5, -self.stampMap.height/2-.5
end

return Stamp
