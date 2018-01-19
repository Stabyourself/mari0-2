local Erase = class("Editor.Erase")

function Erase:initialize(editor)
    self.editor = editor
    
    self.level = self.editor.level
end

function Erase:draw()
    local mouseX, mouseY = getWorldMouse()
    local mapX, mapY = self.level:cameraToMap(mouseX, mouseY)
    local worldX, worldY = self.level:mapToWorld(mapX-1, mapY-1)
    
    GUI.drawBox(self.editor.selectImg, self.editor.selectQuad, worldX, worldY, 16, 16)
end

function Erase:update(dt)
    if self.penDown then
        local x, y = self.level:cameraToMap(getWorldMouse())
            
        self.level:setMap(x, y, nil)
    end
end

function Erase:mousepressed(x, y, button)
    if (button == 1 and cmdDown("editor.pipette")) or button == 3 then
        self:pipette(x, y)
        
    elseif button == 1 then
        self.penDown = true
        
    end
    
    return true
end

function Erase:mousereleased(x, y, button)
    if self.penDown then
        self.editor:saveState()
        self.penDown = false
    end
end

function Erase:pipette(x, y)
    local mapX, mapY = self.level:mouseToMap()
    
    if self.level:inMap(mapX, mapY) then
        local tile = self.level.map[mapX][mapY]
        
        if tile then
            self.editor:selectTool("paint")
            self.editor.tool.tile = tile
        end
    end
end

return Erase
