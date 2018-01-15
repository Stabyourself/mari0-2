local Select = class("Editor.Select")

local selectImg = love.graphics.newImage("img/editor/selection-preview.png")
local selectQuad = {
    love.graphics.newQuad(0, 0, 2, 2, 5, 5),
    love.graphics.newQuad(2, 0, 1, 2, 5, 5),
    love.graphics.newQuad(3, 0, 2, 2, 5, 5),
    love.graphics.newQuad(0, 2, 2, 1, 5, 5),
    love.graphics.newQuad(2, 2, 1, 1, 5, 5),
    love.graphics.newQuad(3, 2, 2, 1, 5, 5),
    love.graphics.newQuad(0, 3, 2, 2, 5, 5),
    love.graphics.newQuad(2, 3, 1, 2, 5, 5),
    love.graphics.newQuad(3, 3, 2, 2, 5, 5),
}

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
            GUI.drawBox(selectImg, selectQuad, x, y, w, h)
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
    
    if keyDown("editor.select.add") and keyDown("editor.select.subtract") then
        font:print("&Intersect;", mx-9, my+2)
    elseif keyDown("editor.select.add") then
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
        
        if keyDown("editor.select.add") and keyDown("editor.select.subtract") then
            self.editor:intersectSelection(tiles)
        elseif keyDown("editor.select.add") then
            self.editor:addToSelection(tiles)
        elseif keyDown("editor.select.subtract") then
            self.editor:subtractFromSelection(tiles)
        elseif #tiles > 1 then
            self.editor:replaceSelection(tiles)
        else
            self.editor:clearSelection()
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
        lx, rx, ty, by = self.editor.level:getMapRectangle(x, y, w, h, true)
    end
    
    local ret = {}
    
    for x = lx, rx do
        for y = ty, by do
            table.insert(ret, {x=x, y=y})
        end
    end
    
    return ret
end

return Select
