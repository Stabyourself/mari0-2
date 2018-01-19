local Stamp = class("Editor.Stamp")

function Stamp:initialize(editor)
    self.editor = editor
    self.level = self.editor.level

    self.stampMap = self.editor.tileMap.stampMaps[1]
    self.dragging = false
end

function Stamp:draw()
    local mouseX, mouseY = self.level:getMouse()
    local offset = {self:getOffset()}
    local mapX, mapY = self.level:cameraToMap(mouseX+offset[1]*16, mouseY+offset[2]*16)

    for x = 1, self.stampMap.width do
        for y = 1, self.stampMap.height do
            local tileX = (mapX+x-1)*16
            local tileY = (mapY+y-1)*16
            
            local tile = self.stampMap.map[x] and self.stampMap.map[x][y]

            if tile then
                tile:draw(tileX, tileY, true)
            end
        end
    end
end

function Stamp:mousepressed(x, y, button)
    if button == 1 then
        self.dragging = true
    end
end

function Stamp:mousereleased(x, y, button)
    if button == 1 and self.dragging then
        local offset = {self:getOffset()}
        local mapX, mapY = self.level:cameraToMap(x+offset[1]*16, y+offset[2]*16)

        self:stamp(mapX, mapY)
    end
end

function Stamp:stamp(mapX, mapY)
    for x = 1, self.stampMap.width do
        for y = 1, self.stampMap.height do
            local tileX = mapX+x
            local tileY = mapY+y

            self.level:setMap(tileX, tileY, self.stampMap.map[x][y])
        end
    end

    self.editor:saveState()
end

function Stamp:getOffset()
    return -self.stampMap.width/2-.5, -self.stampMap.height/2-.5
end

return Stamp
