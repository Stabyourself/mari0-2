local Stamp = class("Editor.Stamp")

function Stamp:initialize(editor)
    self.editor = editor
    self.level = self.editor.level

    self.stampMap = self.editor.tileMap.stampMaps[1]
    self.dragging = false
end

function Stamp:draw()
    if self.stampMap then
        local mouseX, mouseY = self.level:getMouse()
        local worldX, worldY = self.level:cameraToWorld(mouseX, mouseY)

        if self.stampMap.type == "simple" then
            local offsetX, offsetY = self:getOffset()

            worldX = worldX+offsetX*16
            worldY = worldY+offsetY*16
        end

        local coordX, coordY = self.level:worldToCoordinate(worldX, worldY)
        
        if self.stampMap.type == "simple" then
            self.stampMap:draw(coordX, coordY)
            
        elseif self.stampMap.type == "quads" then
            if self.dragging then
                local startX, startY = self.dragStart[1], self.dragStart[2]
                local w, h = coordX-startX+1, coordY-startY+1
                
                if w < 1 then
                    startX = startX + w-1
                    w = -w+2
                end
                
                if h < 1 then
                    startY = startY + h-1
                    h = -h+2
                end

                self.stampMap:draw(startX, startY, w, h)

                love.graphics.setColor(1, 1, 1)
                self.editor:drawSizeHelp(w, h)
            else
                local tileX, tileY = self.level:coordinateToWorld(coordX-1, coordY-1)
                self.stampMap.map[1][1]:draw(tileX, tileY, true)
            end
        end
    end
end

function Stamp:mousepressed(x, y, button)
    if button == 1 then
        self.dragging = true
        
        local coordX, coordY = self.level:cameraToCoordinate(x, y)
        
        self.dragStart = {coordX, coordY}
    end
end

function Stamp:mousereleased(x, y, button)
    if self.stampMap and button == 1 and self.dragging then
        if self.stampMap.type == "simple" then
            local offset = {self:getOffset()}
            local worldX, worldY = self.level:cameraToWorld(x, y)
            worldX = worldX+offset[1]*16
            worldY = worldY+offset[2]*16
            local coordX, coordY = self.level:worldToCoordinate(worldX, worldY)
            
            self:stamp(coordX, coordY)
        
        elseif self.stampMap.type == "quads" then
            local coordX, coordY = self.level:cameraToCoordinate(x, y)
            
            self:stamp(self.dragStart[1], self.dragStart[2], coordX-self.dragStart[1]+1, coordY-self.dragStart[2]+1)
        end
        
        self.dragging = false
    end
end

function Stamp:stamp(x, y, w, h)
    self.stampMap:stamp(self.editor.activeLayer, x, y, w, h)

    self.editor:saveState()
end

function Stamp:getOffset()
    return -self.stampMap.width/2-.5, -self.stampMap.height/2-.5
end

return Stamp
