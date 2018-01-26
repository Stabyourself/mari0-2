local Element = class("Gui3.Element")

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

    self.absPos = {0, 0}
    
    self.scrollable = {false, false}
    self.hasScrollbar = {false, false}
    self.scrolling = {false, false}
    self.scrollingDragOffset = {0, 0}
    self.scrollbarSize = {17, 17}
    self.scroll = {0, 0}

    self.posMin = {0, 0}
    self.posMax = {0, 0}
    self.sizeMin = {0, 0}
    
    self.dragPos = {0, 0}
    self.resizePos = {0, 0}
    
    self.mouse = {0, 0}
    
    self.childBox = {0, 0, self.w, self.h}
    
    self.visible = true
    self.mouseBlocked = true
    
    self.children = {}
end

function Element:resize(w, h)
    self.w = w
    self.h = h
    
    self.childBox[1] = 0
    self.childBox[2] = 0
    self.childBox[3] = self.w
    self.childBox[4] = self.h
end

function Element:addChild(element)
    assert(self ~= element, "You can't add an element to itself. That's stupid.")
    element.gui = self.gui
    element.parent = self
    table.insert(self.children, element)
    
    element:onAssign()
end

function Element:removeChild(element)
    for i, v in ipairs(self.children) do
        if v == element then
            table.remove(self.children, i)
        end
    end
end

function Element:update(dt, x, y, mouseBlocked, absX, absY)
    if x then -- child element
        self.absPos[1] = absX
        self.absPos[2] = absY
    else -- root
        x, y = love.mouse.getPosition()
        x, y = x/VAR("scale"), y/VAR("scale")

        mouseBlocked = false

        self.absPos[1] = self.x
        self.absPos[2] = self.y
    end
    
    self.mouse[1] = x
    self.mouse[2] = y
    self.mouseBlocked = mouseBlocked or not self.visible

    local childMouseBlocked = self.mouseBlocked

    if not self.noClip then
        if  self.mouse[1] < self.childBox[1] or self.mouse[1] >= self.childBox[1]+self:getInnerWidth() or
            self.mouse[2] < self.childBox[2] or self.mouse[2] >= self.childBox[2]+self:getInnerHeight() then
            childMouseBlocked = true
        end
    end

    local siblingsBlocked = false

    for i = #self.children, 1, -1 do
        local v = self.children[i]
        
        if v.update then
            local childX = self.mouse[1]-self.childBox[1]-v.x+self.scroll[1]
            local childY = self.mouse[2]-self.childBox[2]-v.y+self.scroll[2]

            local childAbsX = self.absPos[1]+v.x-self.scroll[1]+self.childBox[1]
            local childAbsY = self.absPos[2]+v.y-self.scroll[2]+self.childBox[2]
            
            local b = v:update(dt, childX, childY, childMouseBlocked, childAbsX, childAbsY)

            if v.visible and b then
                siblingsBlocked = true
                childMouseBlocked = true
            end
        end
    end

    -- Update scroll bar visibility
    self.hasScrollbar[1] = false
    self.hasScrollbar[2] = false

    local childrenW, childrenH

    if self.scrollable[1] or self.scrollable[2] then
        childrenW, childrenH = self:getChildrenSize()
        
        if self.scrollable[1] and childrenW > self:getInnerWidth() then
            self.hasScrollbar[1] = true
        end

        if self.scrollable[2] and childrenH > self:getInnerHeight() then
            self.hasScrollbar[2] = true
            
            if self.scrollable[1] and childrenW > self:getInnerWidth() then
                self.hasScrollbar[1] = true
            end
        end
        
        self.scrollbarSize[1] = math.max(4, (self:getInnerWidth()/childrenW)*(self.childBox[3]-self.scrollbarSpace))
        self.scrollbarSize[2] = math.max(4, (self:getInnerHeight()/childrenH)*(self.childBox[4]-self.scrollbarSpace))
    end
    
    if self.draggable then
        if self.dragging then
            self.x = self.parent.mouse[1]-self.parent.childBox[1]-self.dragPos[1]+self.parent.scroll[1]
            self.y = self.parent.mouse[2]-self.parent.childBox[2]-self.dragPos[2]+self.parent.scroll[2]
        end
    end

    if self.resizeable then
        if self.resizing then
            self.w = self.parent.mouse[1]-self.parent.childBox[1]-self.x+self.resizePos[1]+self.parent.scroll[1]
            self.h = self.parent.mouse[2]-self.parent.childBox[2]-self.y+self.resizePos[2]+self.parent.scroll[2]

            if not self.parent.scrollable[1] then
                self.w = math.min(self.parent:getInnerWidth()-self.x-self.posMax[1], self.w)
            end

            if not self.parent.scrollable[2] then
                self.h = math.min(self.parent:getInnerHeight()-self.y-self.posMax[2], self.h)
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
            self.w = math.min(self.parent:getInnerWidth()-self.posMax[1]-self.posMin[1], self.w)
            self.x = math.min(self.parent:getInnerWidth()-self.w-self.posMax[1], self.x)
        end

        if not self.parent.scrollable[2] then
            self.h = math.min(self.parent:getInnerHeight()-self.posMax[2]-self.posMin[2], self.h)
            self.y = math.min(self.parent:getInnerHeight()-self.h-self.posMax[2], self.y)
        end
    end

    if (self.scrolling[1] or self.scrolling[2]) and not childrenW then
        childrenW, childrenH = self:getChildrenSize()
    end

    if self.scrolling[1] then
        local factor = ((self.mouse[1]-self.scrollingDragOffset[1]-self.childBox[1])/(self.childBox[3]-self.scrollbarSize[1]-self.scrollbarSpace))
        
        factor = math.clamp(factor, 0, 1)
        self.scroll[1] = factor*(childrenW-self:getInnerWidth())

        self.scroll[1] = math.min(childrenW-self:getInnerWidth(), self.scroll[1])
        self.scroll[1] = math.max(0, self.scroll[1])
    end
    
    
    if self.scrolling[2] then
        local factor = ((self.mouse[2]-self.scrollingDragOffset[2]-self.childBox[2])/(self.childBox[4]-self.scrollbarSize[2]-self.scrollbarSpace))
        
        factor = math.clamp(factor, 0, 1)
        self.scroll[2] = factor*(childrenH-self:getInnerHeight())
    
        self.scroll[2] = math.min(childrenH-self:getInnerHeight(), self.scroll[2])
        self.scroll[2] = math.max(0, self.scroll[2])
    end

    return (self.noClip and siblingsBlocked) or (self.mouse[1] > 0 and self.mouse[1] <= self.w and self.mouse[2] > 0 and self.mouse[2] <= self.h)
end

function Element:translate()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
end

function Element:unTranslate()
    love.graphics.pop()
end

function Element:draw()
    local scissorX, scissorY, scissorW, scissorH = love.graphics.getScissor()
    if not self.noClip then
        love.graphics.intersectScissor((self.absPos[1]+self.childBox[1])*VAR("scale"), (self.absPos[2]+self.childBox[2])*VAR("scale"), math.round(self.childBox[3]*VAR("scale")), math.round(self.childBox[4]*VAR("scale")))
    end

    love.graphics.translate(-self.scroll[1]+self.childBox[1], -self.scroll[2]+self.childBox[2])

    for _, v in ipairs(self.children) do
        if v.visible then
            v:draw()
        end
    end
    
    love.graphics.translate(self.scroll[1]-self.childBox[1], self.scroll[2]-self.childBox[2])

    love.graphics.setScissor(scissorX, scissorY, scissorW, scissorH)
    
    for i = 1, 2 do
        if self.scrollable[i] and self.hasScrollbar[i] then
            local pos = self:getScrollbarPos(i)
            
            local img = self.gui.img.scrollbar
            
            if self.scrolling[i] then
                img = self.gui.img.scrollbarActive
            elseif self:scrollCollision(i, self.mouse[1], self.mouse[2]) then
                img = self.gui.img.scrollbarHover
            end

            if i == 1 then
                love.graphics.draw(self.gui.img.scrollbarBack, self.childBox[1], self.childBox[2]+self.childBox[4]-4, 0, self.childBox[3], 1, 0, 4)
                
                love.graphics.draw(img, scrollbarQuad[1], pos, self.childBox[2]+self.childBox[4]-4, 0, 1, 1, 0, 4)
                love.graphics.draw(img, scrollbarQuad[2], pos+1, self.childBox[2]+self.childBox[4]-4, 0, self.scrollbarSize[i]-2, 1, 0, 4)
                love.graphics.draw(img, scrollbarQuad[3], pos-1+self.scrollbarSize[i], self.childBox[2]+self.childBox[4]-4, 0, 1, 1, 0, 4)
            else
                love.graphics.draw(self.gui.img.scrollbarBack, self.childBox[1]+self.childBox[3]-4, self.childBox[2], math.pi/2, self.childBox[4], 1, 0, 4)
        
                love.graphics.draw(img, scrollbarQuad[1], self.childBox[1]+self.childBox[3]-4, pos, math.pi/2, 1, 1, 0, 4)
                love.graphics.draw(img, scrollbarQuad[2], self.childBox[1]+self.childBox[3]-4, pos + 1, math.pi/2, self.scrollbarSize[i]-2, 1, 0, 4)
                love.graphics.draw(img, scrollbarQuad[3], self.childBox[1]+self.childBox[3]-4, pos - 1 + self.scrollbarSize[i], math.pi/2, 1, 1, 0, 4)
            end
        end
    end
end

function Element:scrollCollision(i, x, y)
    local pos = self:getScrollbarPos(i)
    
    if i == 1 then
        return x >= pos and x < pos + self.scrollbarSize[1] and y >= self.childBox[2]+self.childBox[4]-8 and y < self.childBox[2]+self.childBox[4]
    else
        return x >= self.childBox[1]+self.childBox[3]-8 and x < self.childBox[1]+self.childBox[3] and y >= pos and y < pos + self.scrollbarSize[2]
    end
end

function Element:getScrollbarPos(i)
    local childrenW, childrenH = self:getChildrenSize()
    
    if i == 1 then
        return (self.scroll[1]/(childrenW-self:getInnerWidth()))*(self.childBox[3]-self.scrollbarSize[1]-self.scrollbarSpace)+self.childBox[1]
    else
        return (self.scroll[2]/(childrenH-self:getInnerHeight()))*(self.childBox[4]-self.scrollbarSize[2]-self.scrollbarSpace)+self.childBox[2]
    end
end

function Element:getInnerHeight()
    local h = self.childBox[4]

    if self.hasScrollbar[1] then
        h = h - 8
    end

    return h
end

function Element:getInnerWidth()
    local w = self.childBox[3]

    if self.hasScrollbar[2] then
        w = w - 8
    end

    return w
end

function Element:mousepressed(x, y, button)
    local toReturn = false
    
    if self.scrollable[1] and self.hasScrollbar[1] and self:scrollCollision(1, x, y) then
        self.scrolling[1] = true
        self.scrollingDragOffset[1] = x-self:getScrollbarPos(1)

        toReturn = true
    end

    if self.scrollable[2] and self.hasScrollbar[2] and self:scrollCollision(2, x, y) then
        self.scrolling[2] = true
        self.scrollingDragOffset[2] = y-self:getScrollbarPos(2)

        toReturn = true
    end
    
    for i = #self.children, 1, -1 do
        local v = self.children[i]
        
        if v.mousepressed then
            local lx = x-self.childBox[1]-v.x+self.scroll[1]
            local ly = y-self.childBox[2]-v.y+self.scroll[2]

            local b = v:mousepressed(lx, ly, button)

            if b then
                toReturn = true
            end
            
            if lx >= 0 and lx < v.w and ly >= 0 and ly < v.h and not v.mouseBlocked then
                -- push that element to the end
                if v.movesToTheFront then
                    table.insert(self.children, table.remove(self.children, i))
                end

                toReturn = true
            end
        end
    end
    
    return toReturn
end

function Element:mousereleased(x, y, button)
    self.scrolling[1] = false
    self.scrolling[2] = false

    for _, v in ipairs(self.children) do
        if v.mousereleased then
            v:mousereleased(x-self.childBox[1]-v.x+self.scroll[1], y-self.childBox[2]-v.y+self.scroll[2], button)
        end
    end
end

function Element:wheelmoved(x, y)
    if not self.mouseBlocked then
        if self.hasScrollbar[2] and y ~= 0 then
            self.scroll[2] = self.scroll[2] - y*17
            
            return true
        end
        
        -- scroll horizontally if there's no y scrolling
        if not self.hasScrollbar[2] and self.hasScrollbar[1] and y ~= 0 then
            self.scroll[1] = self.scroll[1] - y*17
            
            return true
        end
        
        if self.hasScrollbar[1] and x ~= 0 then
            self.scroll[1] = self.scroll[1] - x*17
            
            return true
        end
    end
    
    for _, v in ipairs(self.children) do
        if v.wheelmoved then
            if  v.mouse[1] > 0 and v.mouse[1] < v.w and
                v.mouse[2] > 0 and v.mouse[2] < v.h then 
                if v:wheelmoved(x, y, button) then
                    return true
                end
            end
        end
    end
end

function Element:getChildrenSize()
    local w = 0
    local h = 0
    
    for _, v in ipairs(self.children) do
        if v.x+v.w+v.posMax[1] > w then
            w = v.x+v.w+v.posMax[1]
        end
        
        if v.y+v.h+v.posMax[2] > h then
            h = v.y+v.h+v.posMax[2]
        end
    end
    
    return w, h
end

function Element:autoSize()
    local w, h = self:getChildrenSize()
    
    self.w = self.childBox[1]*2+w
    self.h = self.childBox[2]*2+h
    
    self.childBox[3] = w
    self.childBox[4] = h
end

function Element:onAssign() end
    
return Element
