local Paint = class("Editor.Paint")

function Paint:initialize(editor)
    self.editor = editor
    
    self.level = self.editor.level
    self.penDown = false
    self.tile = self.editor.tileMap.tiles[1]
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
    local coordX, coordY = self.level:mouseToCoordinate()
    local layer = self.editor.activeLayer

    if layer:inMap(coordX, coordY) then
        local tile = layer:getTile(coordX, coordY)
        
        if tile then
            self.tile = tile
        else
            self.editor:selectTool("erase")
        end
    end
end

return Paint
