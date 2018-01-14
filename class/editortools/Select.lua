local Select = class("Editor.Select")

function Select:initialize(editor)
    self.editor = editor
    
    self.pressing = false
end

function Select:draw()
    local mx, my = self.editor.level:mouseToWorld()
    
    if self.pressing then
        love.graphics.rectangle("line", self.selectionStart[1], self.selectionStart[2], mx-self.selectionStart[1], my-self.selectionStart[2])
    end
    
    love.graphics.setColor(0, 0, 0)
    
    if keyDown("editor.select.add") then
        font:print("+", mx-9, my+2)
    elseif keyDown("editor.select.subtract") then
        font:print("-", mx-9, my+2)
    end
    
    love.graphics.setColor(1, 1, 1)
end

function Select:mousepressed(x, y, button)
    if button == 1 then
        local mx, my = self.editor.level:mouseToWorld()
        self.pressing = true
        self.selectionStart = {mx, my}
    end
        
    return true
end

function Select:mousereleased(x, y, button)
    local mx, my = self.editor.level:mouseToWorld()
    if self.pressing then
        local tiles = self:getTiles(self.selectionStart[1], self.selectionStart[2], mx-self.selectionStart[1], my-self.selectionStart[2])
        
        if keyDown("editor.select.add") then
            self.editor:addToSelection(tiles)
        elseif keyDown("editor.select.subtract") then
            self.editor:subtractFromSelection(tiles)
        else
            self.editor:replaceSelection(tiles)
        end
    end
    
    self.pressing = false
end

function Select:getTiles(x, y, w, h)
    local lx, rx, ty, by
    
    if math.abs(w) < 3 and math.abs(h) < 3 then
        lx, ty = self.editor.level:worldToMap(x, y)
        rx, by = lx, ty
    else
        if w < 0 then
            x = x + w
            w = -w
        end
        
        if h < 0 then
            y = y + h
            h = -h
        end
        
        lx, ty = self.editor.level:worldToMap(x+8, y+8)
        rx, by = self.editor.level:worldToMap(x+w-8, y+h-8)
    end
    
    if lx > self.editor.level.width or rx < 1 or ty > self.editor.level.height or by < 1 then -- selection is completely outside map
        return {}
    end
    
    lx = math.max(lx, 1)
    rx = math.min(rx, self.editor.level.width)
    ty = math.max(ty, 1)
    by = math.min(by, self.editor.level.height)
    
    local ret = {}
    
    for x = lx, rx do
        for y = ty, by do
            table.insert(ret, {x=x, y=y})
        end
    end
    
    return ret
end

return Select
