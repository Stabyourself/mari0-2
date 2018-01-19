local Paint = class("Editor.Paint")

function Paint:initialize(editor)
    self.editor = editor
    
    self.level = self.editor.level
    self.penDown = false
    self.tile = self.editor.tileMap.tiles[1]
end

function Paint:update(dt)
    if self.penDown then
        local x, y = self.level:cameraToMap(getWorldMouse())
        
        if not self.level:inMap(x, y) then
            self.editor:expandMapTo(x, y)
        end
        
        self.level:setMap(x, y, self.tile)
    end
end

function Paint:draw()
    local mouseX, mouseY = getWorldMouse()
    local mapX, mapY = self.level:cameraToMap(mouseX, mouseY)
    local worldX, worldY = self.level:mapToWorld(mapX-1, mapY-1)
    
    self.tile:draw(worldX, worldY, true)
end

function Paint:mousepressed(x, y, button)
    if (button == 1 and cmdDown("editor.pipette")) or button == 3 then
        self:pipette(x, y)
        
    elseif button == 1 then
        self.penDown = true
        
    end
    
    return true
end

function Paint:mousereleased(x, y, button)
    if self.penDown then
        self.penDown = false

        self.editor:saveState()
    end
end

function Paint:pipette(x, y)
    local mapX, mapY = self.level:mouseToMap()
    
    if self.level:inMap(mapX, mapY) then
        local tile = self.level:getTile(mapX, mapY)
        
        if tile then
            self.tile = tile
        else
            self.editor:selectTool("erase")
        end
    end
end

return Paint
