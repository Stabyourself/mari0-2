local Wand = class("Editor.Wand")

function Wand:initialize(editor)
    self.editor = editor
    
    self.level = self.editor.level
    self.pressing = false
end

function Wand:draw()
    local mx, my = self.level:mouseToWorld()
    
    local addition = ""
    
    if cmdDown("editor.wand.global") then
        addition = addition .. "G"
    end
    
    if cmdDown("editor.select.add") and cmdDown("editor.select.subtract") then
        addition = addition .. "^"
    elseif cmdDown("editor.select.add") then
        addition = addition .. "+"
    elseif cmdDown("editor.select.subtract") then
        addition = addition .. "-"
    end
    
    if addition ~= "" then
        love.graphics.print(addition, mx-#addition*8-1, my+2)
    end
end

function Wand:mousepressed(x, y, button)
    if button == 1 then
        self.pressingPos = {self.level:cameraToMap(x, y)}
        self.pressing = true
    end
    
    return true
end

function Wand:mousereleased(x, y, button)
    if button == 1 and self.pressing then
        mx, my = self.level:cameraToMap(x, y)
        
        if mx == self.pressingPos[1] and my == self.pressingPos[2] then
            local tiles
            
            if cmdDown("editor.wand.global") then
                local referenceTile = self.level:getTile(mx, my)
                tiles = {}
                
                for y = 1, self.level.height do
                    for x = 1, self.level.width do
                        local tile = self.level:getTile(x, y)
                        
                        if tile == referenceTile then
                            table.insert(tiles, {x, y})
                        end
                    end
                end
            else
                tiles = self.level:getFloodArea(mx, my)
            end
            
            if cmdDown("editor.select.add") and cmdDown("editor.select.subtract") then
                self.editor:intersectSelection(tiles)
            elseif cmdDown("editor.select.add") then
                self.editor:addToSelection(tiles)
            elseif cmdDown("editor.select.subtract") then
                self.editor:subtractFromSelection(tiles)
            else
                self.editor:replaceSelection(tiles)
            end
            
            self.editor:saveState()
        end
    end
    
    self.pressing = false
end

return Wand
