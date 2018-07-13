local Erase = class("Editor.Erase")

function Erase:initialize(editor)
    self.editor = editor

    self.level = self.editor.level
end

function Erase:draw()
    local mouseX, mouseY = getWorldMouse()
    local coordX, coordY = self.level:cameraToCoordinate(mouseX, mouseY)
    local worldX, worldY = self.level:coordinateToWorld(coordX-1, coordY-1)

    Gui3.drawBox(self.editor.selectImg, self.editor.selectQuad, worldX, worldY, 16, 16)
end

function Erase:update(dt)
    if self.penDown then
        local x, y = self.level:cameraToCoordinate(getWorldMouse())
        local layer = self.editor.activeLayer

        if layer:inMap(x, y) then
            layer:setCoordinate(x, y, nil)
            layer:optimize()
        end
    end
end

function Erase:mousepressed(x, y, button)
    if (button == 1 and controls3.cmdDown("editor.pipette")) or button == 3 then
        self.editor:pipette()

    elseif button == 1 then
        self.penDown = true

    end

    return true
end

function Erase:mousereleased(x, y, button)
    if self.penDown then
        self.editor:mapChanged()
        self.penDown = false
    end
end

return Erase
