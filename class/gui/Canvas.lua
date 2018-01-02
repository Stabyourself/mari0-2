local Canvas = class("GUI.Canvas")

function Canvas:initialize(gui, x, y, w, h)
    self.gui = gui
    
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    
    self.children = {}
    self.backgroundColor = {0, 0, 0, 0}
end

function Canvas:addChild(element)
    element.gui = self.gui
    element.parent = self
    table.insert(self.children, element)
end

function Canvas:removeChild(element)
    for i, v in ipairs(self.children) do
        if v == element then
            table.remove(self.children, i)
        end
    end
end

function Canvas:update(dt)
    for _, v in ipairs(self.children) do
        if v.update then
            v:update(dt)
        end
    end
end

function Canvas:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", 0, 0, self.w, self.h)
    
    for _, v in ipairs(self.children) do
        v:draw()
    end
    
    love.graphics.pop()
end

function Canvas:mousepressed(x, y, button)
    x, y = x-self.x, y-self.y
    
    for i = #self.children, 1, -1 do
        local v = self.children[i]
        
        if v.mousepressed then
            if v:mousepressed(x, y, button) then
                -- push that element to the end
                table.insert(self.children, table.remove(self.children, i))
                
                return
            end
        end
    end
end

function Canvas:mousereleased(x, y, button)
    x, y = x-self.x, y-self.y
    
    for _, v in ipairs(self.children) do
        if v.mousereleased then
            v:mousereleased(x, y, button)
        end
    end
end

function Canvas:getMouse()
    local x, y = getWorldMouse()
    
    return x-self.x, y-self.y
end
    
return Canvas
