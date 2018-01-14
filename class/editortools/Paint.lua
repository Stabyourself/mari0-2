local Paint = class("Editor.Paint")

function Paint:initialize(editor)
    self.editor = editor
    
    self.penDown = false
    self.tile = 1
end

function Paint:update(dt)
    if self.penDown then
        local x, y = self.editor.level:cameraToMap(getWorldMouse())
            
        self.editor.level:setMap(x, y, self.tile)
    end
end

function Paint:draw()
    local mouseX, mouseY = getWorldMouse()
    local mapX, mapY = self.editor.level:cameraToMap(mouseX, mouseY)
    local worldX, worldY = self.editor.level:mapToWorld(mapX-1, mapY-1)
    
    self.editor.level.tileMap.tiles[self.tile]:draw(worldX, worldY, true)
end

function Paint:mousepressed(x, y, button)
    if (button == 1 and keyDown("editor.pipette")) or button == 3 then
        self:pipette(x, y)
        
    elseif button == 1 then
        self.penDown = true
        
    end
    
    return true
end

function Paint:mousereleased(x, y, button)
    self.penDown = false
end

function Paint:pipette(x, y)
    local mapX, mapY = self.editor.level:mouseToMap()
    
    if self.editor.level:inMap(mapX, mapY) then
        self.tile = self.editor.level.map[mapX][mapY]
        
        if self.tile == 0 then
            self.tile = 1
            self.editor:selectTool("erase")
        end
    end
end

return Paint
