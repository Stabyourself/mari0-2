local Gui3 = ...
Gui3.Element = class("Gui3.Element")

local scrollbarQuad = {
    love.graphics.newQuad(0, 0, 1, 8, 3, 8),
    love.graphics.newQuad(1, 0, 1, 8, 3, 8),
    love.graphics.newQuad(2, 0, 1, 8, 3, 8),
}

Gui3.Element.scrollbarSpace = 8

function Gui3.Element:initialize(x, y, w, h)
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

function Gui3.Element:resize(w, h)
    self.w = w
    self.h = h

    self.childBox[1] = 0
    self.childBox[2] = 0
    self.childBox[3] = self.w
    self.childBox[4] = self.h
end

function Gui3.Element:addChild(element)
    assert(self ~= element, "You can't add an element to itself. That's stupid.")
    element.gui = self.gui
    element.parent = self
    table.insert(self.children, element)

    element:onAssign()
end

function Gui3.Element:removeChild(element)
    for i, child in ipairs(self.children) do
        if child == element then
            table.remove(self.children, i)
        end
    end
end

function Gui3.Element:clearChildren()
    iClearTable(self.children)
end

function Gui3.Element:update(dt, x, y, mouseBlocked, absX, absY)

    -- Update scroll bar visibility
    self.hasScrollbar[1] = false
    self.hasScrollbar[2] = false

    self.childrenW, self.childrenH = self:getChildrenSize()

    if self.scrollable[1] or self.scrollable[2] then
        if self.scrollable[1] and self.childrenW > self:getInnerWidth() then
            self.hasScrollbar[1] = true
        end

        if self.scrollable[2] and self.childrenH > self:getInnerHeight() then
            self.hasScrollbar[2] = true

            if self.scrollable[1] and self.childrenW > self:getInnerWidth() then
                self.hasScrollbar[1] = true
            end
        end

        self.scrollbarSize[1] = math.max(4, (self:getInnerWidth()/self.childrenW)*(self.childBox[3]-self.scrollbarSpace))
        self.scrollbarSize[2] = math.max(4, (self:getInnerHeight()/self.childrenH)*(self.childBox[4]-self.scrollbarSpace))
    end

    if self.draggable then
        if self.dragging then
            self.x = self.parent.mouse[1]-self.parent.childBox[1]-self.dragPos[1]+self.parent.scroll[1]
            self.y = self.parent.mouse[2]-self.parent.childBox[2]-self.dragPos[2]+self.parent.scroll[2]
        end
    end

    if self.resizeable then
        if self.resizing then
            local w = self.w
            local h = self.h

            self.w = self.parent.mouse[1]-self.parent.childBox[1]-self.x+self.resizePos[1]+self.parent.scroll[1]
            self.h = self.parent.mouse[2]-self.parent.childBox[2]-self.y+self.resizePos[2]+self.parent.scroll[2]

            if not self.parent.scrollable[1] then
                self.w = math.min(self.parent:getInnerWidth()-self.x-self.posMax[1], self.w)
            end

            if not self.parent.scrollable[2] then
                self.h = math.min(self.parent:getInnerHeight()-self.y-self.posMax[2], self.h)
            end

            if (self.w ~= w or self.h ~= h) then
                self:sizeChanged()
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

    if self.scrolling[1] then
        local factor = ((self.mouse[1]-self.scrollingDragOffset[1]-self.childBox[1])/(self.childBox[3]-self.scrollbarSize[1]-self.scrollbarSpace))

        factor = math.clamp(factor, 0, 1)
        self.scroll[1] = factor*(self.childrenW-self:getInnerWidth())
    end


    if self.scrolling[2] then
        local factor = ((self.mouse[2]-self.scrollingDragOffset[2]-self.childBox[2])/(self.childBox[4]-self.scrollbarSize[2]-self.scrollbarSpace))

        factor = math.clamp(factor, 0, 1)
        self.scroll[2] = factor*(self.childrenH-self:getInnerHeight())
    end

    self:limitScroll()

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

    if self.clip then
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

    return (not self.clip and siblingsBlocked) or (self.mouse[1] > 0 and self.mouse[1] <= self.w and self.mouse[2] > 0 and self.mouse[2] <= self.h)
end

function Gui3.Element:limitScroll()
    self.scroll[1] = math.min(self.childrenW-self:getInnerWidth(), self.scroll[1])
    self.scroll[1] = math.max(0, self.scroll[1])

    self.scroll[2] = math.min(self.childrenH-self:getInnerHeight(), self.scroll[2])
    self.scroll[2] = math.max(0, self.scroll[2])
end

function Gui3.Element:translate()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
end

function Gui3.Element:unTranslate()
    love.graphics.pop()
end

function Gui3.Element:draw()
    local scissorX, scissorY, scissorW, scissorH

    if self.clip then
        scissorX, scissorY, scissorW, scissorH = love.graphics.getScissor()
        love.graphics.intersectScissor((self.absPos[1]+self.childBox[1])*VAR("scale"), (self.absPos[2]+self.childBox[2])*VAR("scale"), math.round(self.childBox[3]*VAR("scale")), math.round(self.childBox[4]*VAR("scale")))
    end

    love.graphics.translate(-self.scroll[1]+self.childBox[1], -self.scroll[2]+self.childBox[2])

    for _, child in ipairs(self.children) do
        if child.visible then
            child:draw()
        end
    end

    love.graphics.translate(self.scroll[1]-self.childBox[1], self.scroll[2]-self.childBox[2])

    if self.clip then
        love.graphics.setScissor(scissorX, scissorY, scissorW, scissorH)
    end

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

function Gui3.Element:scrollCollision(i, x, y)
    local pos = self:getScrollbarPos(i)

    if i == 1 then
        return x >= pos and x < pos + self.scrollbarSize[1] and y >= self.childBox[2]+self.childBox[4]-8 and y < self.childBox[2]+self.childBox[4]
    else
        return x >= self.childBox[1]+self.childBox[3]-8 and x < self.childBox[1]+self.childBox[3] and y >= pos and y < pos + self.scrollbarSize[2]
    end
end

function Gui3.Element:getScrollbarPos(i)
    if i == 1 then
        return (self.scroll[1]/(self.childrenW-self:getInnerWidth()))*(self.childBox[3]-self.scrollbarSize[1]-self.scrollbarSpace)+self.childBox[1]
    else
        return (self.scroll[2]/(self.childrenH-self:getInnerHeight()))*(self.childBox[4]-self.scrollbarSize[2]-self.scrollbarSpace)+self.childBox[2]
    end
end

function Gui3.Element:getInnerHeight()
    local h = self.childBox[4]

    if self.hasScrollbar[1] then
        h = h - 8
    end

    return h
end

function Gui3.Element:getInnerWidth()
    local w = self.childBox[3]

    if self.hasScrollbar[2] then
        w = w - 8
    end

    return w
end

function Gui3.Element:mousepressed(x, y, button)
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

    -- custom hook
    if self.hookmousepressed then
        self.hookmousepressed(x, y, button)
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

function Gui3.Element:mousereleased(x, y, button)
    self.scrolling[1] = false
    self.scrolling[2] = false

    for _, child in ipairs(self.children) do
        if child.mousereleased then
            child:mousereleased(x-self.childBox[1]-child.x+self.scroll[1], y-self.childBox[2]-child.y+self.scroll[2], button)
        end
    end
end

function Gui3.Element:wheelmoved(x, y)
    if not self.mouseBlocked then
        if self.hasScrollbar[2] and y ~= 0 then
            self.scroll[2] = self.scroll[2] - y*17
            self:limitScroll()

            return true
        end

        -- scroll horizontally if there's no y scrolling
        if not self.hasScrollbar[2] and self.hasScrollbar[1] and y ~= 0 then
            self.scroll[1] = self.scroll[1] - y*17
            self:limitScroll()

            return true
        end

        if self.hasScrollbar[1] and x ~= 0 then
            self.scroll[1] = self.scroll[1] - x*17
            self:limitScroll()

            return true
        end
    end

    for _, child in ipairs(self.children) do
        if child.wheelmoved then
            if  child.mouse[1] > 0 and child.mouse[1] < child.w and
                child.mouse[2] > 0 and child.mouse[2] < child.h then
                if child:wheelmoved(x, y, button) then
                    return true
                end
            end
        end
    end
end

function Gui3.Element:getChildrenSize()
    local w = 0
    local h = 0

    for _, child in ipairs(self.children) do
        if not child.ignoreForParentSize then
            local childW = child.x+child.w+child.posMax[1]
            local childH = child.y+child.h+child.posMax[2]

            w = math.max(w, childW)
            h = math.max(h, childH)
        end
    end

    return w, h
end

function Gui3.Element:autoSize()
    local w, h = self:getChildrenSize()

    self.w = self.childBox[1]*2+w
    self.h = self.childBox[2]*2+h

    self.childBox[3] = w
    self.childBox[4] = h
end

function Gui3.Element:sizeChanged() end

function Gui3.Element:onAssign() end
