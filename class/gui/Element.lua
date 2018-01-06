local Element = class("GUI.Element")

local scrollbarQuad = {
    love.graphics.newQuad(0, 0, 1, 8, 3, 8),
    love.graphics.newQuad(1, 0, 1, 8, 3, 8),
    love.graphics.newQuad(2, 0, 1, 8, 3, 8),
}

Element.scrollbarSpace = 8

function Element:initialize(x, y, w, h)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    
    self.scrollable = {x=false, y=false}
    self.hasScrollbar = {x=false, y=false}
    self.scrolling = {x=false, y=false}
    self.scrollingDragOffset = Vector(0, 0)
    self.scrollbarSize = Vector(17, 17)
    self.scroll = Vector(0, 0)

    self.posMin = Vector(0, 0)
    self.sizeMin = Vector(0, 0)
    
    self.dragPos = Vector(0, 0)
    self.resizePos = Vector(0, 0)
    
    self.mouse = Vector(0, 0)
    
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

function Element:update(dt, x, y)
    if not x then
        x, y = love.mouse.getPosition()
        x, y = x/VAR("scale"), y/VAR("scale")
    end
    
    self.mouse.x = x
    self.mouse.y = y
    
    for _, v in ipairs(self.children) do
        if v.update then
            v:update(dt, x-v.x+self.scroll.x, y-v.y+self.scroll.y)
        end
    end

    -- Update scroll bar visibility
    self.hasScrollbar = {x=false, y=false}

    local childrenW, childrenH = self:getChildrenSize()

    if childrenW > self.w then
        self.hasScrollbar.x = true
    end

    if childrenH > self:getInnerHeight() then
        self.hasScrollbar.y = true
        
        if childrenW > self:getInnerWidth() then
            self.hasScrollbar.x = true
        end
    end
    
    self.scrollbarSize.x = math.max(4, (self:getInnerWidth()/childrenW)*(self.w-self.scrollbarSpace))
    self.scrollbarSize.y = math.max(4, (self:getInnerHeight()/childrenH)*(self.h-self.scrollbarSpace))
 
    if self.draggable then
        if self.dragging then
            self.x = self.parent.mouse.x-self.dragPos.x+self.parent.scroll.x
            self.y = self.parent.mouse.y-self.dragPos.y+self.parent.scroll.y
        end
    end

    if self.resizeable then
        if self.resizing then
            self.w = self.parent.mouse.x-self.x+self.resizePos.x+self.parent.scroll.x
            self.h = self.parent.mouse.y-self.y+self.resizePos.y+self.parent.scroll.y

            if not self.parent.scrollable.x then
                self.w = math.min(self.parent:getInnerWidth()-self.x, self.w)
            end

            if not self.parent.scrollable.y then
                self.h = math.min(self.parent:getInnerHeight()-self.y, self.h)
            end
        end
    end

    --limit x, y, w and h
    --lower
    
    self.w = math.max(self.sizeMin.x, self.w)
    self.h = math.max(self.sizeMin.y, self.h)

    self.x = math.max(self.posMin.x, self.x)
    self.y = math.max(self.posMin.y, self.y)
    
    if self.resizeable and self.parent then
        --upper
        if not self.parent.scrollable.x then
            self.w = math.min(self.parent:getInnerWidth()-self.posMin.x, self.w)
            self.x = math.min(self.parent.w-self.w, self.x)
        end

        if not self.parent.scrollable.y then
            self.h = math.min(self.parent:getInnerHeight()-self.posMin.y, self.h)
            self.y = math.min(self.parent:getInnerHeight()-self.h, self.y)
        end
    end

    local childrenW, childrenH = self:getChildrenSize()
    
    if self.scrolling.x then
        local factor = ((self.mouse.x-self.scrollingDragOffset.x)/(self.w-self.scrollbarSize.x-self.scrollbarSpace))
        
        factor = math.clamp(factor, 0, 1)
        self.scroll.x = factor*(childrenW-self:getInnerWidth())
    end
    
    self.scroll.x = math.min(childrenW-self:getInnerWidth(), self.scroll.x)
    self.scroll.x = math.max(0, self.scroll.x)
    
    if self.scrolling.y then
        local factor = ((self.mouse.y-self.scrollingDragOffset.y)/(self.h-self.scrollbarSize.y-self.scrollbarSpace))
        
        factor = math.clamp(factor, 0, 1)
        self.scroll.y = factor*(childrenH-self:getInnerHeight())
    end
    
    self.scroll.y = math.min(childrenH-self:getInnerHeight(), self.scroll.y)
    self.scroll.y = math.max(0, self.scroll.y)
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
    love.graphics.translate(-self.scroll.x, -self.scroll.y)

    level = level or 1
    for _, v in ipairs(self.children) do
        v:draw(level+1)
    end
    
    love.graphics.translate(self.scroll.x, self.scroll.y)
    
    for _, i in pairs({"x", "y"}) do
        if self.scrollable[i] and self.hasScrollbar[i] then
            local pos = self:getScrollbarPos(i)
            
            local img = self.gui.img.scrollbar
            
            if self.scrolling[i] then
                img = self.gui.img.scrollbarActive
            elseif self:scrollCollision(i, self.mouse.x, self.mouse.y) then
                img = self.gui.img.scrollbarHover
            end

            if i == "x" then
                love.graphics.draw(self.gui.img.scrollbarBack, 0, self.h-4, 0, self.w, 1, 0, 4)
                
                love.graphics.draw(img, scrollbarQuad[1], pos, self.h-4, 0, 1, 1, 0, 4)
                love.graphics.draw(img, scrollbarQuad[2], pos + 1, self.h-4, 0, self.scrollbarSize[i]-2, 1, 0, 4)
                love.graphics.draw(img, scrollbarQuad[3], pos - 1 + self.scrollbarSize[i], self.h-4, 0, 1, 1, 0, 4)
            else
                love.graphics.draw(self.gui.img.scrollbarBack, self.w-4, 0, math.pi/2, self.h, 1, 0, 4)
        
                love.graphics.draw(img, scrollbarQuad[1], self.w-4, pos, math.pi/2, 1, 1, 0, 4)
                love.graphics.draw(img, scrollbarQuad[2], self.w-4, pos + 1, math.pi/2, self.scrollbarSize[i]-2, 1, 0, 4)
                love.graphics.draw(img, scrollbarQuad[3], self.w-4, pos - 1 + self.scrollbarSize[i], math.pi/2, 1, 1, 0, 4)
            end
        end
    end
end

function Element:scrollCollision(i, x, y)
    local pos = self:getScrollbarPos(i)
    
    if i == "x" then
        return x >= pos and x < pos + self.scrollbarSize.x and y >= self.h-8 and y < self.h
    else
        return x >= self.w-8 and x < self.w and y >= pos and y < pos + self.scrollbarSize.y
    end
end

function Element:getScrollbarPos(i)
    local childrenW, childrenH = self:getChildrenSize()
    
    if i == "x" then
        return (self.scroll.x/(childrenW-self:getInnerWidth()))*(self.w-self.scrollbarSize.x-self.scrollbarSpace)
    else
        return (self.scroll.y/(childrenH-self:getInnerHeight()))*(self.h-self.scrollbarSize.y-self.scrollbarSpace)
    end
end

function Element:getInnerHeight()
    local h = self.h

    if self.hasScrollbar.x then
        h = h - 8
    end

    return h
end

function Element:getInnerWidth()
    local w = self.w

    if self.hasScrollbar.y then
        w = w - 8
    end

    return w
end

function Element:mousepressed(x, y, button)
    if self.scrollable.x and self.hasScrollbar.x and self:scrollCollision("x", x, y) then
        self.scrolling.x = true
        self.scrollingDragOffset.x = x-self:getScrollbarPos("x")

        return true
    end

    if self.scrollable.y and self.hasScrollbar.y and self:scrollCollision("y", x, y) then
        self.scrolling.y = true
        self.scrollingDragOffset.y = y-self:getScrollbarPos("y")

        return true
    end

    if x >= 0 and x < self:getInnerWidth() and y >= 0 and y < self:getInnerHeight() then
        for i = #self.children, 1, -1 do
            local v = self.children[i]
            
            if v.mousepressed then
                if v:mousepressed(x-v.x+self.scroll.x, y-v.y+self.scroll.y, button) then
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
            v:mousereleased(x-v.x+self.scroll.x, y-v.y+self.scroll.y, button)
        end
    end
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
