local Wand = class("Editor.Wand")

function Wand:initialize(editor)
    self.editor = editor
    
    self.pressing = false
end

function Wand:draw()
    local mx, my = self.editor.level:mouseToWorld()
    
    love.graphics.setColor(0, 0, 0)
    
    local addition = ""
    
    if keyDown("editor.wand.global") then
        addition = addition .. "G"
    end
    
    if keyDown("editor.select.add") and keyDown("editor.select.subtract") then
        addition = addition .. "&Intersect;"
    elseif keyDown("editor.select.add") then
        addition = addition .. "+"
    elseif keyDown("editor.select.subtract") then
        addition = addition .. "-"
    end
    
    font:getLength(addition)
    
    if addition ~= "" then
        font:print(addition, mx-font:getLength(addition)*8-1, my+2)
    end
    
    love.graphics.setColor(1, 1, 1)
end

function Wand:mousepressed(x, y, button)
    if button == 1 then
        self.pressingPos = {self.editor.level:cameraToMap(x, y)}
        self.pressing = true
    end
    
    return true
end

function Wand:mousereleased(x, y, button)
    if button == 1 and self.pressing then
        mx, my = self.editor.level:cameraToMap(x, y)
        
        if mx == self.pressingPos[1] and my == self.pressingPos[2] then
            local tiles
            
            if keyDown("editor.wand.global") then
                local referenceTile = self.editor.level:getTile(mx, my)
                tiles = {}
                
                for y = 1, self.editor.level.height do
                    for x = 1, self.editor.level.width do
                        local tile = self.editor.level:getTile(x, y)
                        
                        if tile == referenceTile then
                            table.insert(tiles, {x=x, y=y})
                        end
                    end
                end
            else
                tiles = self.editor.level:getFloodArea(mx, my)
            end
                
            if keyDown("editor.select.add") and keyDown("editor.select.subtract") then
                self.editor:intersectSelection(tiles)
            elseif keyDown("editor.select.add") then
                self.editor:addToSelection(tiles)
            elseif keyDown("editor.select.subtract") then
                self.editor:subtractFromSelection(tiles)
            else
                self.editor:replaceSelection(tiles)
            end
        end
    end
    
    self.pressing = false
end

return Wand
