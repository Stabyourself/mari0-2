local Wand = class("Editor.Wand")

function Wand:initialize(editor)
    self.editor = editor
    
    self.level = self.editor.level
    self.pressing = false
end

function Wand:draw()
    local mx, my = self.level:mouseToWorld()
    
    local len = 0
    local addition = ""
    
    if cmdDown("editor.wand.global") then
        addition = addition .. "G"
        len = len + 1
    end
    
    if cmdDown("editor.select.add") and cmdDown("editor.select.subtract") then
        addition = addition .. "∩"
        len = len + 1
    elseif cmdDown("editor.select.add") then
        addition = addition .. "+"
        len = len + 1
    elseif cmdDown("editor.select.subtract") then
        addition = addition .. "-"
        len = len + 1
    end
    
    if addition ~= "" then
        love.graphics.print(addition, mx-len*8-1, my+2)
    end
end

function Wand:mousepressed(x, y, button)
    if button == 1 then
        self.pressingPos = {self.level:cameraToCoordinate(x, y)}
        self.pressing = true
    end
    
    return true
end

function Wand:mousereleased(x, y, button)
    if button == 1 and self.pressing then
        mx, my = self.level:cameraToCoordinate(x, y)
        
        if mx == self.pressingPos[1] and my == self.pressingPos[2] then
            local tiles
            
            if cmdDown("editor.wand.global") then
                local referenceTile = self.editor.activeLayer:getTile(mx, my)
                tiles = {}
                
                for y = self.editor.activeLayer:getYStart(), self.editor.activeLayer:getYEnd() do
                    for x = self.editor.activeLayer:getXStart(), self.editor.activeLayer:getXEnd() do
                        local tile = self.editor.activeLayer:getTile(x, y)
                        
                        if tile == referenceTile then
                            table.insert(tiles, {x, y})
                        end
                    end
                end
            else
                tiles = self.editor.activeLayer:getFloodArea(mx, my)
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
