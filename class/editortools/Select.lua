local Select = class("Editor.Select")

function Select:initialize(editor)
    self.editor = editor
    
    self.pressing = false
end

function Select:draw()
    local mx, my = self.editor.level:mouseToWorld()
    
    if self.pressing then
        local lx, rx, ty, by = self.editor.level:getMapRectangle(self.selectionStart[1], self.selectionStart[2], mx-self.selectionStart[1], my-self.selectionStart[2])
        local x = (lx-1)*self.editor.level.tileSize
        local y = (ty-1)*self.editor.level.tileSize
        local w = (rx-lx+1)*self.editor.level.tileSize
        local h = (by-ty+1)*self.editor.level.tileSize
        
        if w > 0 and h > 0 then
            GUI.drawBox(self.editor.selectImg, self.editor.selectQuad, x, y, w, h)
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
        -- love.graphics.rectangle("line", (lx-1)*self.editor.level.tileSize, (ty-1)*self.editor.level.tileSize, (rx-lx+1)*self.editor.level.tileSize, (by-ty+1)*self.editor.level.tileSize)
    end
    
    love.graphics.setColor(0, 0, 0)
    
    if cmdDown("editor.select.add") and cmdDown("editor.select.subtract") then
        font:print("&Intersect;", mx-9, my+2)
    elseif cmdDown("editor.select.add") then
        font:print("+", mx-9, my+2)
    elseif cmdDown("editor.select.subtract") then
        font:print("-", mx-9, my+2)
    end
    
    love.graphics.setColor(1, 1, 1)
end

function Select:mousepressed(x, y, button)
    if button == 1 then
        local worldX, worldY = self.editor.level:mouseToWorld()
        
        if not cmdDown("editor.select.add") and not cmdDown("editor.select.subtract") and self.editor.selection and self.editor.selection:collision() then
            self.editor.selection:startDrag(worldX, worldY)
        else
            self.editor:unFloatSelection()
            local worldX, worldY = self.editor.level:mouseToWorld()
            self.pressing = true
            self.selectionStart = {worldX, worldY}
        end
    end
        
    return true
end

function Select:mousereleased(x, y, button)
    local mx, my = self.editor.level:mouseToWorld()
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
        lx, ty = self.editor.level:worldToMap(x, y)
        rx, by = lx, ty
        dirtySelect = true
    else
        lx, rx, ty, by = self.editor.level:getMapRectangle(x, y, w, h, true)
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
