local Select = class("Editor.Select")

function Select:initialize(editor)
    self.editor = editor
    self.level = self.editor.level
    
    self.pressing = false
end

function Select:draw()
    local mouseX, mouseY = self.level:getMouse()
    local worldX, worldY = self.level:mouseToWorld()
    local mapX, mapY = self.level:mouseToMap()
    
    if self.pressing then
        local lx, rx, ty, by = self.level:getMapRectangle(self.selectionStart[1], self.selectionStart[2], worldX-self.selectionStart[1], worldY-self.selectionStart[2])
        local x = (lx-1)*self.level.tileSize
        local y = (ty-1)*self.level.tileSize
        local w = (rx-lx+1)*self.level.tileSize
        local h = (by-ty+1)*self.level.tileSize
        
        if w > 0 and h > 0 then
            Gui3.drawBox(self.editor.selectImg, self.editor.selectQuad, x, y, w, h)
        elseif w > 0 or h > 0 then -- line
            love.graphics.setColor(0, 0, 0)
            if w == 0 then
                x = x - 1
                w = 2
            end
            
            if h == 0 then
                y = y - 1
                h = 2
            end
            
            love.graphics.rectangle("fill", x, y, w, h)
            love.graphics.setColor(1, 1, 1)
        end
        -- love.graphics.rectangle("line", (lx-1)*self.level.tileSize, (ty-1)*self.level.tileSize, (rx-lx+1)*self.level.tileSize, (by-ty+1)*self.level.tileSize)
    end

    local addition = ""
    
    if not self.editor.floatingSelection or not self.editor.floatingSelection.dragging then
        if cmdDown("editor.select.add") and cmdDown("editor.select.subtract") then
            addition = "&Intersect;"
        elseif cmdDown("editor.select.add") then
            addition = "+"
        elseif cmdDown("editor.select.subtract") then
            addition = "-"
        elseif  self.editor.selection and self.editor.selection:collision(mouseX, mouseY) or
                self.editor.floatingSelection and self.editor.floatingSelection:collision(mouseX, mouseY) then
            addition = "&Move;"
        end
    end

    if addition ~= "" then
        fontOutlined:print(addition, worldX-font:getLength(addition)*8-1, worldY+2)
    end
end

function Select:mousepressed(x, y, button)
    if button == 1 then
        local worldX, worldY = self.level:mouseToWorld()
        
        if self.editor.selection and not cmdDown("editor.select.add") and not cmdDown("editor.select.subtract") and self.editor.selection:collision(x, y) then
            self.editor:floatSelection()
            self.editor.floatingSelection:startDrag(worldX, worldY)
        elseif self.editor.floatingSelection and self.editor.floatingSelection:collision(x, y) then
            self.editor.floatingSelection:startDrag(worldX, worldY)
        else
            self.editor:unFloatSelection()

            local worldX, worldY = self.level:mouseToWorld()
            self.pressing = true
            self.selectionStart = {worldX, worldY}
        end
    end
        
    return true
end

function Select:mousereleased(x, y, button)
    local mx, my = self.level:mouseToWorld()
    if self.pressing then
        local tiles, dirty = self:getTiles(self.selectionStart[1], self.selectionStart[2], mx-self.selectionStart[1], my-self.selectionStart[2])
        
        if cmdDown("editor.select.add") and cmdDown("editor.select.subtract") then
            self.editor:intersectSelection(tiles)
        elseif cmdDown("editor.select.add") then
            self.editor:addToSelection(tiles)
        elseif cmdDown("editor.select.subtract") then
            self.editor:subtractFromSelection(tiles)
        elseif #tiles > 0 and not dirty then
            self.editor:replaceSelection(tiles)
        else
            self.editor:clearSelection()
        end
        
        self.editor:saveState()
        
        self.pressing = false
    end
end

function Select:getTiles(x, y, w, h)
    local lx, rx, ty, by
    local dirtySelect = false
    
    if math.abs(w) < 3 and math.abs(h) < 3 then
        lx, ty = self.level:worldToMap(x, y)
        rx, by = lx, ty
        dirtySelect = true
    else
        lx, rx, ty, by = self.level:getMapRectangle(x, y, w, h, true)
    end
    
    local ret = {}
    
    for x = lx, rx do
        for y = ty, by do
            table.insert(ret, {x, y})
        end
    end
    
    return ret, dirtySelect
end

function Select:unSelect()
    self.editor:unFloatSelection()
end

return Select
