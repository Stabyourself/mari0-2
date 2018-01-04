local Element = class("GUI.Element")

function Element:initialize(x, y, w, h)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    
    self.children = {}
end

function Element:addChild(element)
    -- assert(self == element, "You can't add an element to itself. That's stupid.")
    element.gui = self.gui
    element.parent = self
    table.insert(self.children, element)
end

function Element:removeChild(element)
    for i, v in ipairs(self.children) do
        if v == element then
            table.remove(self.children, i)
        end
    end
end

function Element:update(dt)
    for _, v in ipairs(self.children) do
        if v.update then
            v:update(dt)
        end
    end
end

function Element:translate()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
end

function Element:unTranslate()
    love.graphics.pop()
end

function Element:stencil(level, clear)
    level = level or 1
    
    love.graphics.stencil(function()
        love.graphics.rectangle("fill", 0, 0, self.w, self.h)
    end, "increment", 1, not clear)
    
    love.graphics.setStencilTest("equal", level)
end

function Element:unStencil(level)
    level = level or 1
    
    love.graphics.stencil(function()
        love.graphics.rectangle("fill", 0, 0, self.w, self.h)
    end, "decrement", 1, true)
    
    if level > 1 then
        love.graphics.setStencilTest("equal", level-1)
    else -- Clean up after the root element (likely the canvas)
        love.graphics.stencil(function() end)
        love.graphics.setStencilTest()
    end 
end

function Element:draw(level)
    level = level or 1
    for _, v in ipairs(self.children) do
        v:draw(level+1)
    end
end

function Element:mousepressed(x, y, button)
    for i = #self.children, 1, -1 do
        local v = self.children[i]
        
        if v.mousepressed then
            local x, y = v:getMouse()
            
            if v:mousepressed(x, y, button) then
                -- push that element to the end
                table.insert(self.children, table.remove(self.children, i))
                
                return true
            end
        end
    end
end

function Element:mousereleased(x, y, button)
    for _, v in ipairs(self.children) do
        local x, y = v:getMouse()
        
        if v.mousereleased then
            v:mousereleased(x, y, button)
        end
    end
end

function Element:getMouse()
    local x, y
    if self.parent then
        x, y = self.parent:getMouse()
    else
        x, y = getWorldMouse()
    end
    
    return x-self.x, y-self.y
end

function Element:getInnerSize()
    local w = 0
    local h = 0
    
    for _, v in ipairs(self.children) do
        if v.x+v.w > w then
            w = v.x+v.w
        end
        
        if v.y+v.h > h then
            h = v.y+v.h
        end
    end
    
    return w, h
end
    
return Element
