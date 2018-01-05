local Element = class("GUI.Element")

local scrollbarQuad = {
    love.graphics.newQuad(0, 0, 1, 8, 3, 8),
    love.graphics.newQuad(1, 0, 1, 8, 3, 8),
    love.graphics.newQuad(2, 0, 1, 8, 3, 8),
}

Element.scrollbarSpace = 0

function Element:initialize(x, y, w, h)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    
    self.scrollable = {false, false}
    self.hasScrollbar = {false, false}
    self.scrolling = {false, false}
    self.scrollingDragOffset = {0, 0}
    self.scrollbarSize = {17, 17}
    self.scroll = {0, 0}

    self.posMin = {0, 0}
    self.sizeMin = {0, 0}
    
    self.children = {}
end

function Element:addChild(element)
    assert(self ~= element, "You can't add an element to itself. That's stupid.")
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

    -- Update scroll bar visibility
    self.hasScrollbar = {false, false}

    local childrenW, childrenH = self:getChildrenSize()

    if childrenW > self.w then
        self.hasScrollbar[1] = true
    end

    if childrenH > self:getInnerHeight() then
        self.hasScrollbar[2] = true
        
        if childrenW > self:getInnerWidth() then
            self.hasScrollbar[1] = true
        end
    end
    
    self.scrollbarSize[1] = math.max(4, (self:getInnerWidth()/childrenW)*(self.w-self.scrollbarSpace))
    self.scrollbarSize[2] = math.max(4, (self:getInnerHeight()/childrenH)*(self.h-self.scrollbarSpace))
 
    if self.draggable then
        if self.dragging then
            local x, y = self.parent:getMouse()
            
            self.x = x-self.dragPos[1]+self.parent.scroll[1]
            self.y = y-self.dragPos[2]+self.parent.scroll[2]
        end
    end

    if self.resizeable then
        if self.resizing then
            local x, y = self.parent:getMouse()
            
            self.w = x-self.x+self.resizeX+self.parent.scroll[1]
            self.h = y-self.y+self.resizeY+self.parent.scroll[2]

            if not self.parent.scrollable[1] then
                self.w = math.min(self.parent:getInnerWidth()-self.x, self.w)
            end

            if not self.parent.scrollable[2] then
                self.h = math.min(self.parent:getInnerHeight()-self.y, self.h)
            end
        end
    end

    --limit x, y, w and h
    --lower
    self.w = math.max(self.sizeMin[1], self.w)
    self.h = math.max(self.sizeMin[2], self.h)

    self.x = math.max(self.posMin[1], self.x)
    self.y = math.max(self.posMin[2], self.y)
    
    if self.resizeable and self.parent then
        --upper
        if not self.parent.scrollable[1] then
            self.w = math.min(self.parent.getInnerWidth()-self.posMin[1], self.w)
            self.x = math.min(self.parent.w-self.w, self.x)
        end

        if not self.parent.scrollable[2] then
            self.h = math.min(self.parent:getInnerHeight()-self.posMin[2], self.h)
            self.y = math.min(self.parent:getInnerHeight()-self.h, self.y)
        end
    end

    local childrenW, childrenH = self:getChildrenSize()
    
    if self.scrolling[1] then
        local x, y = self:getMouse()
        
        local factor = ((x-self.scrollingDragOffset[1])/(self.w-self.scrollbarSize[1]-self.scrollbarSpace))
        
        factor = math.clamp(factor, 0, 1)
        self.scroll[1] = factor*(childrenW-self:getInnerWidth())
    end
    
    self.scroll[1] = math.min(childrenW-self:getInnerWidth(), self.scroll[1])
    self.scroll[1] = math.max(0, self.scroll[1])
    
    if self.scrolling[2] then
        local x, y = self:getMouse()
        
        local factor = ((y-self.scrollingDragOffset[2])/(self.h-self.scrollbarSize[2]-self.scrollbarSpace))
        
        factor = math.clamp(factor, 0, 1)
        self.scroll[2] = factor*(childrenH-self:getInnerHeight())
    end
    
    self.scroll[2] = math.min(childrenH-self:getInnerHeight(), self.scroll[2])
    self.scroll[2] = math.max(0, self.scroll[2])
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
    love.graphics.translate(-self.scroll[1], -self.scroll[2])

    level = level or 1
    for _, v in ipairs(self.children) do
        v:draw(level+1)
    end
    
    love.graphics.translate(self.scroll[1], self.scroll[2])
    
    for i = 1, 2 do
        if self.scrollable[i] and self.hasScrollbar[i] then
            local pos = self:getScrollbarPos(i)
            
            local img = self.gui.img.scrollbar
            
            if self:scrollCollision(i, self:getMouse()) or self.scrolling[i] then
                img = self.gui.img.scrollbarHover
            end

            if i == 1 then
                love.graphics.draw(self.gui.img.scrollbarBack, 0, self.h-4, 0, self.w, 1, 0, 4)
                
                love.graphics.draw(img, scrollbarQuad[1], pos, self.h-4, 0, 1, 1, 0, 4)
                love.graphics.draw(img, scrollbarQuad[2], pos + 1, self.h-4, 0, self.scrollbarSize[i]-2, 1, 0, 4)
                love.graphics.draw(img, scrollbarQuad[3], pos - 1 + self.scrollbarSize[i], self.h-4, 0, 1, 1, 0, 4)
            else
                love.graphics.draw(self.gui.img.scrollbarBack, self.w-4, 0, math.pi/2, self.w, 1, 0, 4)
        
                love.graphics.draw(img, scrollbarQuad[1], self.w-4, pos, math.pi/2, 1, 1, 0, 4)
                love.graphics.draw(img, scrollbarQuad[2], self.w-4, pos + 1, math.pi/2, self.scrollbarSize[i]-2, 1, 0, 4)
                love.graphics.draw(img, scrollbarQuad[3], self.w-4, pos - 1 + self.scrollbarSize[i], math.pi/2, 1, 1, 0, 4)
            end
        end
    end
end

function Element:scrollCollision(i, x, y)
    local pos = self:getScrollbarPos(i)
    
    if i == 1 then
        return x >= pos and x < pos + self.scrollbarSize[1] and y >= self.h-8 and y < self.h
    else
        return x >= self.w-8 and x < self.w and y >= pos and y < pos + self.scrollbarSize[2]
    end
end

function Element:getScrollbarPos(i)
    local childrenW, childrenH = self:getChildrenSize()
    
    if i == 1 then
        return (self.scroll[1]/(childrenW-self:getInnerWidth()))*(self.w-self.scrollbarSize[1]-self.scrollbarSpace)
    else
        return (self.scroll[2]/(childrenH-self:getInnerHeight()))*(self.h-self.scrollbarSize[2]-self.scrollbarSpace)
    end
end

function Element:getInnerHeight()
    local h = self.h

    if self.hasScrollbar[1] then
        h = h - 10
    end

    return h
end

function Element:getInnerWidth()
    local w = self.w

    if self.hasScrollbar[2] then
        w = w - 10
    end

    return w
end

function Element:mousepressed(x, y, button)
    if self.scrollable[1] and self.hasScrollbar[1] and self:scrollCollision(1, x, y) then
        self.scrolling[1] = true
        self.scrollingDragOffset[1] = x-self:getScrollbarPos(1)

        return true
    end

    if self.scrollable[2] and self.hasScrollbar[2] and self:scrollCollision(2, x, y) then
        self.scrolling[2] = true
        self.scrollingDragOffset[2] = y-self:getScrollbarPos(2)

        return true
    end

    if x >= 0 and x < self:getInnerWidth() and y >= 0 and y < self:getInnerHeight() then
        for i = #self.children, 1, -1 do
            local v = self.children[i]
            
            if v.mousepressed then
                if v:mousepressed(x-v.x+self.scroll[1], y-v.y+self.scroll[2], button) then
                    -- push that element to the end
                    table.insert(self.children, table.remove(self.children, i))
                    
                    return true
                end
            end
        end
    end
end

function Element:mousereleased(x, y, button)
    self.scrolling = {false, false}

    for _, v in ipairs(self.children) do
        if v.mousereleased then
            v:mousereleased(x-v.x+self.scroll[1], y-v.y+self.scroll[2], button)
        end
    end
end

function Element:getMouse(inner)
    local x, y
    if self.parent then
        x, y = self.parent:getMouse(true)
    else
        x, y = getWorldMouse()
    end
    
    if inner then
        x, y = x+self.scroll[1], y+self.scroll[2]
    end

    return x-self.x, y-self.y
end

function Element:getChildrenSize()
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
