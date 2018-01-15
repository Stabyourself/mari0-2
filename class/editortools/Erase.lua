local Erase = class("Editor.Erase")

function Erase:initialize(editor)
    self.editor = editor
end

function Erase:update(dt)
    if self.penDown then
        local x, y = self.editor.level:cameraToMap(getWorldMouse())
            
        self.editor.level:setMap(x, y, nil)
    end
end

function Erase:mousepressed(x, y, button)
    if (button == 1 and keyDown("editor.pipette")) or button == 3 then
        self:pipette(x, y)
        
    elseif button == 1 then
        self.penDown = true
        
    end
    
    return true
end

function Erase:mousereleased(x, y, button)
    self.penDown = false
end

function Erase:pipette(x, y)
    local mapX, mapY = self.editor.level:mouseToMap()
    
    if self.editor.level:inMap(mapX, mapY) then
        local tile = self.editor.level.map[mapX][mapY]
        
        if tile then
            self.editor:selectTool("paint")
            self.editor.tool.tile = tile
        end
    end
end

return Erase
