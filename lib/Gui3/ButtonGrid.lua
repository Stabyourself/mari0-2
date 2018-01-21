ButtonGrid = class("Gui3.Button", Gui3.Element)

ButtonGrid.perRow = 73
ButtonGrid.size = {16, 16}
ButtonGrid.gutter = {1, 1}

function ButtonGrid:initialize(x, y, img, buttons, func)
    self.img = img
    self.buttons = buttons
    self.func = func
    
    Gui3.Element.initialize(self, x, y, 0, 0)
    
    self:updateSize()
    
    self.selected = nil
end

function ButtonGrid:update(dt, x, y, mouseBlocked)
    Gui3.Element.update(self, dt, x, y, mouseBlocked)
    
    local maxWidth = self.parent:getInnerWidth()
    
    self.perRow = math.max(1, math.floor((maxWidth-self.x)/(self.size[1]+self.gutter[1])))
    
    self:updateSize()
end

function ButtonGrid:updateSize()
    self.w = self.perRow*(self.size[1]+self.gutter[1])-self.gutter[1]
    self.h = math.ceil(#self.buttons/self.perRow)*(self.size[2]+self.gutter[2])
end

function ButtonGrid:getCollision(x, y)
    if self.mouseBlocked then
        return false
    end
    
    local tileX = math.ceil(x/(self.size[1]+self.gutter[1]))
    local tileY = math.ceil(y/(self.size[2]+self.gutter[2]))
    
    if tileX < 1 or tileX > self.perRow or
        tileY < 1 or tileY > math.ceil(#self.buttons/self.perRow) then
        return false
    end
    
    return (tileY-1)*self.perRow+tileX
end 

function ButtonGrid:draw(level)
    Gui3.Element.translate(self)
    
    love.graphics.setColor(1, 1, 1)
    
    local mouseTile = self:getCollision(self.mouse[1], self.mouse[2])
    
    local topY = math.ceil((self.parent.scroll[2]-self.y)/(self.size[2]+self.gutter[2]))
    local bottomY = math.ceil((self.parent.scroll[2]-self.y)/(self.size[2]+self.gutter[2]) + (self.parent:getInnerHeight())/(self.size[2]+self.gutter[2]))
    
    for tileY = topY, bottomY do
        for tileX = 1, self.perRow do
            local tileNum = (tileY-1)*self.perRow+tileX
            
            if self.buttons[tileNum] then
                local x = (tileX-1)*(self.size[1] + self.gutter[1])
                local y = (tileY-1)*(self.size[2] + self.gutter[2])
                
                love.graphics.draw(self.img, self.buttons[tileNum], x, y)
                
                if tileNum == mouseTile then
                    love.graphics.setColor(1, 1, 1, 0.7)
                    love.graphics.rectangle("fill", x, y, self.size[1], self.size[2])
                    love.graphics.setColor(1, 1, 1, 1)
                end
            end
        end
    end
    
    if self.selected then
        local tileX = (self.selected-1)%self.perRow+1
        local tileY = math.ceil(self.selected/self.perRow)-1
        
        local x = (tileX-1)*(self.size[1] + self.gutter[1])
        local y = tileY*(self.size[2] + self.gutter[2])
        
        Gui3.drawBox(self.gui.img.box, Gui3.boxQuad, x-2, y-3, 20, 22)
    end
    
    Gui3.Element.draw(self, level)
    
    Gui3.Element.unTranslate(self)
end

function ButtonGrid:mousepressed(x, y, button)
    local col = self:getCollision(x, y)
    
    if col then
        self.func(self, col)
    end
    
    return Gui3.Element.mousepressed(self, x, y, button)
end

return ButtonGrid
