local Fill = class("Editor.Fill")

function Fill:initialize(editor)
    self.editor = editor
    
    self.level = self.editor.level
end

function Fill:mousepressed(x, y, button)
    if button == 1 then
        self.pressingPos = {self.level:cameraToMap(x, y)}
        self.pressing = true
    elseif button == 3 then
        self.editor.tools.paint:pipette(x, y)
    end
    
    return true
end

function Fill:draw()
    local mouseX, mouseY = getWorldMouse()
    local mapX, mapY = self.level:cameraToMap(mouseX, mouseY)
    local worldX, worldY = self.level:mapToWorld(mapX-1, mapY-1)
    
    self.editor.tools.paint.tile:draw(worldX, worldY, true)
end

function Fill:mousereleased(x, y, button)
    if button == 1 and self.pressing then
        x, y = self.level:cameraToMap(x, y)
        
        if x == self.pressingPos[1] and y == self.pressingPos[2] then
            if self.editor.selection and #self.editor.selection.tiles > 0 then
                local found = false
                
                for _, v in ipairs(self.editor.selection.tiles) do
                    if v[1] == x and v[2] == y then
                        found = true
                        break
                    end
                end
                
                if found then
                    self:fillTiles(self.editor.selection.tiles, self.editor.tools.paint.tile)
                    self.editor:saveState()
                    return
                end
            end
            
            -- local tiles = self.level:getFloodArea(x, y)
            local tiles = self.level:getFloodAreaScanline(x, y)
            
            self:fillTiles(tiles, self.editor.tools.paint.tile)
            self.editor:saveState()
        end
    end
    
    self.pressing = false
end

function Fill:fillTiles(tiles, tile)
    for _, v in ipairs(tiles) do
        self.level:setMap(v[1], v[2], tile)
    end
end

return Fill
