local Paint = class("Editor.Paint")

function Paint:initialize(editor)
    self.editor = editor
    
    self.level = self.editor.level
    self.penDown = false
    self.tile = self.level.tileMaps[1].tiles[1]
end

function Paint:update(dt)
    if self.penDown then
        local x, y = self.level:cameraToCoordinate(getWorldMouse())
        local layer = self.editor.activeLayer

        if not layer:inMap(x, y) then
            layer:expandTo(x, y)
        end
        
        layer:setCoordinate(x, y, self.tile)
        layer:optimize()
    end
end

function Paint:draw()
    local mouseX, mouseY = getWorldMouse()
    local coordX, coordY = self.level:cameraToCoordinate(mouseX, mouseY)
    local worldX, worldY = self.level:coordinateToWorld(coordX-1, coordY-1)
    
    love.graphics.setColor(1, 1, 1, 0.5)
    self.tile:draw(worldX, worldY)
    love.graphics.setColor(1, 1, 1)
end

function Paint:mousepressed(x, y, button)
    if (button == 1 and cmdDown("editor.pipette")) or button == 3 then
        self.editor:pipette(x, y)
        
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

return Paint
