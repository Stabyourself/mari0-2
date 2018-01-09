ButtonGrid = class("GUI.Button", GUI.Element)

ButtonGrid.perRow = 73
ButtonGrid.size = Vector(16, 16)
ButtonGrid.gutter = Vector(1, 1)

function ButtonGrid:initialize(x, y, img, buttons, func)
    self.img = img
    self.buttons = buttons
    
    GUI.Element.initialize(self, x, y, 0, 0)
    
    self:updateSize()
    
    self.func = func --boogie nights
end

function ButtonGrid:update(dt, x, y, mouseBlocked)
    GUI.Element.update(self, dt, x, y, mouseBlocked)
    
    local maxWidth = self.parent:getInnerWidth()
    
    self.perRow = math.max(1, math.floor((maxWidth-self.x)/(self.size.x+self.gutter.x)))
    
    self:updateSize()
end

function ButtonGrid:updateSize()
    self.w = self.perRow*(self.size.x+self.gutter.x)-self.gutter.x
    self.h = math.ceil(#self.buttons/self.perRow*(self.size.y+self.gutter.y)-self.gutter.y)
end

function ButtonGrid:getCollision(x, y)
    if self.mouseBlocked then
        return false
    end
    
    local tileX = math.ceil(x/(self.size.x+self.gutter.x))
    local tileY = math.ceil(y/(self.size.y+self.gutter.y))
    
    if tileX < 1 or tileX > self.perRow or
        tileY < 1 or tileY > math.ceil(#self.buttons/self.perRow) then
        return false
    end
    
    return (tileY-1)*self.perRow+tileX
end 

function ButtonGrid:draw(level)
    GUI.Element.translate(self)
    
    love.graphics.setColor(1, 1, 1)
    
    local mouseTile = self:getCollision(self.mouse.x, self.mouse.y)
    
    for i = 1, #self.buttons do
        local tileX = (i-1)%self.perRow+1
        local tileY = math.ceil(i/self.perRow)-1
        
        local topY = math.floor((self.parent.scroll.y-self.y)/(self.size.y+self.gutter.y))
        local bottomY = math.floor((self.parent.scroll.y-self.y)/(self.size.y+self.gutter.y) + (self.parent:getInnerHeight())/(self.size.y+self.gutter.y))
        
        if tileY >= topY and tileY <= bottomY then
            local x = (tileX-1)*(self.size.x + self.gutter.x)
            local y = tileY*(self.size.y + self.gutter.y)
            
            love.graphics.draw(self.img, self.buttons[i], x, y)
            
            if i == mouseTile then
                love.graphics.setColor(1, 1, 1, 0.7)
                love.graphics.rectangle("fill", x, y, self.size.x, self.size.y)
                love.graphics.setColor(1, 1, 1, 1)
            end
            
        end
    end
    
    GUI.Element.draw(self, level)
    
    GUI.Element.unTranslate(self)
end

function ButtonGrid:mousepressed(x, y, button)
    if self:getCollision(x, y) then
        self.func(col)
    end
    
    GUI.Element.mousepressed(self, x, y, button)
end

return ButtonGrid
