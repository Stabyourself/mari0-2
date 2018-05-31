local Fill = class("Editor.Fill")

function Fill:initialize(editor)
    self.editor = editor

    self.level = self.editor.level
end

function Fill:mousepressed(x, y, button)
    if button == 1 then
        self.pressingPos = {self.level:cameraToCoordinate(x, y)}
        self.pressing = true
    elseif button == 3 then
        self.editor:pipette(x, y)
    end

    return true
end

function Fill:draw()
    local mouseX, mouseY = getWorldMouse()
    local coordX, coordY = self.level:cameraToCoordinate(mouseX, mouseY)
    local worldX, worldY = self.level:coordinateToWorld(coordX-1, coordY-1)

    love.graphics.setColor(1, 1, 1, 0.5)
    self.editor.tools.paint.tile:draw(worldX, worldY)
    love.graphics.setColor(1, 1, 1)
end

function Fill:mousereleased(x, y, button)
    if button == 1 and self.pressing then
        x, y = self.level:cameraToCoordinate(x, y)

        if x == self.pressingPos[1] and y == self.pressingPos[2] then
            if self.level:inMap(x, y) then
                if self.editor.selection and #self.editor.selection.tiles > 0 then
                    local found = false

                    for _, tile in ipairs(self.editor.selection.tiles) do
                        if tile[1] == x and tile[2] == y then
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

                local tiles = self.editor.activeLayer:getFloodArea(x, y, self.editor.activeLayer)

                self:fillTiles(tiles, self.editor.tools.paint.tile)
                self.editor:saveState()
            end
        end
    end

    self.pressing = false
end

function Fill:fillTiles(tiles, fillWith)
    for _, tile in ipairs(tiles) do
        self.editor.activeLayer:setCoordinate(tile[1], tile[2], fillWith)
    end
end

return Fill
