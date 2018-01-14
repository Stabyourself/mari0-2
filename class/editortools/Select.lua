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
end

function Select:mousepressed(x, y, button)
    local mx, my = self.editor.level:mouseToWorld()
    self.pressing = true
    self.selectionStart = {mx, my}
    
    return true
end

function Select:mousereleased(x, y, button)
    local mx, my = self.editor.level:mouseToWorld()
    if self.pressing then
        self.editor:replaceSelection(self:getTiles(self.selectionStart[1], self.selectionStart[2], mx-self.selectionStart[1], my-self.selectionStart[2]))
    end
    
    self.pressing = false
end

function Select:getTiles(x, y, w, h)
    if w < 0 then
        x = x + w
        w = -w
    end
    
    if h < 0 then
        y = y + h
        h = -h
    end
    
    local lx, ty = self.editor.level:worldToMap(x, y)
    local rx, by = self.editor.level:worldToMap(x+w, y+h)
    
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
