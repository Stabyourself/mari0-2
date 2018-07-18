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
    self.dragStart = {0, 0}
    self.resizePos = {0, 0}

    self.mouse = {nil, nil}

    self.visible = true

    self.children = {}

    self.childBox = {}

    self.scrollbarHover = {false, false}

    self.childrenW, self.childrenH = self:getChildrenSize()
    self.needsReRender = true
    self:sizeChanged()

    if VAR("debug").canvas then
        self.debugColor = Color3.fromHSL(love.math.random(), 1, 0.5)
    end
end

function Gui3.Element:resize(w, h)
    self.w = w
    self.h = h

    self:sizeChanged()
end

function Gui3.Element:addChild(element)
    assert(self ~= element, "You can't add an element to itself. That's stupid.")
    element.gui = self.gui
    element.parent = self
    table.insert(self.children, element)

    element:onAssign()

    self:updateScrollbars()
end

function Gui3.Element:removeChild(element)
    for i, child in ipairs(self.children) do
        if child == element then
            table.remove(self.children, i)
            self:mouseRegionChanged()
        end
    end
end

function Gui3.Element:clearChildren()
    iClearTable(self.children)
end

function Gui3.Element:getMouseZone(t, index, x, y, boxX, boxY, boxW, boxH)
    if self.visible and not self.noMouseEvents then
        boxX, boxY, boxW, boxH = intersectRectangles(x, y, self.w, self.h, boxX, boxY, boxW, boxH)

        if boxX and boxW > 0 and boxH > 0 then
            if not t[index] then -- this whole thing saves up on memory.
                t[index] = {}
            end

            t[index].x = boxX
            t[index].y = boxY
            t[index].w = boxW
            t[index].h = boxH
            t[index].offsetX = x
            t[index].offsetY = y
            t[index].element = self

            index = index + 1

            boxX, boxY, boxW, boxH = intersectRectangles(x+self.childBox[1], y+self.childBox[2], self:getInnerWidth(), self:getInnerHeight(), boxX, boxY, boxW, boxH)

            if boxX then
                for _, child in ipairs(self.children) do
                    index = child:getMouseZone(
                        t,
                        index,
                        x+child.x-self.scroll[1]+self.childBox[1],
                        y+child.y-self.scroll[2]+self.childBox[2],
                        boxX, boxY,
                        boxW, boxH
                    )
                end
            end
        end
    end

    return index
end

function Gui3.Element:updateScrollbars()
    self.childrenW, self.childrenH = self:getChildrenSize()

    self.hasScrollbar[1] = false
    self.hasScrollbar[2] = false

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

    self:limitScroll()
end

function Gui3.Element:mousemoved(x, y, diffX, diffY)
    self.childrenW, self.childrenH = self:getChildrenSize()

    self.mouse[1] = x
    self.mouse[2] = y

    if self.draggable then
        if self.dragging then
            self.x = self.x + diffX
            self.y = self.y + diffY

            self:positionChanged()
        end
    end

    if self.resizeable then
        if self.resizing then
            local w = self.w
            local h = self.h

            self.w = self.w + diffX
            self.h = self.h + diffY

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

    -- update scrollbar hover states
    for i = 1, 2 do
        if self.scrollable[i] and self.hasScrollbar[i] then
            self:setScrollbarHover(i, self:scrollCollision(i, self.mouse[1], self.mouse[2]))
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
        local oldScroll = self.scroll[1]
        local factor = ((self.mouse[1]-self.scrollingDragOffset[1]-self.childBox[1])/(self.childBox[3]-self.scrollbarSize[1]-self.scrollbarSpace))

        factor = math.clamp(factor, 0, 1)
        self.scroll[1] = factor*(self.childrenW-self:getInnerWidth())
        self:limitScroll()

        if self.scroll[1] ~= oldScroll then
            self:scrollChanged()
            self:mouseRegionChanged()
            self:updateRender()
        end
    end

    if self.scrolling[2] then
        local oldScroll = self.scroll[2]
        local factor = ((self.mouse[2]-self.scrollingDragOffset[2]-self.childBox[2])/(self.childBox[4]-self.scrollbarSize[2]-self.scrollbarSpace))

        factor = math.clamp(factor, 0, 1)
        self.scroll[2] = factor*(self.childrenH-self:getInnerHeight())
        self:limitScroll()

        if self.scroll[2] ~= oldScroll then
            self:scrollChanged()
            self:mouseRegionChanged()
            self:updateRender()
        end
    end
end

function Gui3.Element:scrollChanged()
    for _, child in ipairs(self.children) do
        if child.parentScrollChanged then
            child:parentScrollChanged()
        end
    end
end

function Gui3.Element:mouseentered(x, y)
    self.mouse[1] = x
    self.mouse[2] = y
end

function Gui3.Element:mouseleft(x, y)
    self.mouse[1] = nil
    self.mouse[2] = nil

    for i = 1, 2 do
        self:setScrollbarHover(i, false)
    end
end

function Gui3.Element:setScrollbarHover(i, hovering)
    if hovering ~= self.scrollbarHover[i] then
        self.scrollbarHover[i] = hovering
        self:updateRender()
    end
end

function Gui3.Element:limitScroll()
    self.scroll[1] = math.min(self.childrenW-self:getInnerWidth(), self.scroll[1])
    self.scroll[1] = math.max(0, self.scroll[1])

    self.scroll[2] = math.min(self.childrenH-self:getInnerHeight(), self.scroll[2])
    self.scroll[2] = math.max(0, self.scroll[2])
end

function Gui3.Element:render()
    if self.needsReRender then
        local canvas = love.graphics.getCanvas()
        love.graphics.setCanvas(self.canvas)
        love.graphics.clear(1, 1, 1, 0)

        self:draw()

        love.graphics.setCanvas(canvas)

        self.needsReRender = false
    end
end

function Gui3.Element:rootDraw()
    love.graphics.push()
    love.graphics.origin()
    if self.needsReRender and VAR("debug").reRenders then
        print("Rerender @ " .. love.timer.getTime())
    end

    self:render()

    love.graphics.pop()

    love.graphics.draw(self.canvas, self.x, self.y)

    if VAR("debug").canvas then
        self:debugDraw()
    end
end

function Gui3.Element:draw()
    -- Children
    for _, child in ipairs(self.children) do
        if child.visible and child.canvas then
            child:render()

            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(child.canvas, child.x-self.scroll[1]+self.childBox[1], child.y-self.scroll[2]+self.childBox[2])
        end
    end


    -- Scrollbars
    for i = 1, 2 do
        if self.scrollable[i] and self.hasScrollbar[i] then
            local pos = self:getScrollbarPos(i)

            local img = self.gui.img.scrollbar

            if self.scrolling[i] then
                img = self.gui.img.scrollbarActive
            elseif self.scrollbarHover[i] then
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
    if self.scrollable[1] and self.hasScrollbar[1] and self:scrollCollision(1, x, y) then
        self.scrolling[1] = true
        self.scrollingDragOffset[1] = x-self:getScrollbarPos(1)
        self.exclusiveMouse = true
        self:updateRender()
    end

    if self.scrollable[2] and self.hasScrollbar[2] and self:scrollCollision(2, x, y) then
        self.scrolling[2] = true
        self.scrollingDragOffset[2] = y-self:getScrollbarPos(2)
        self.exclusiveMouse = true
        self:updateRender()
    end

    -- rearrange UI elements
    -- todo: only move to front if not at the front?
    self:moveToFront()

    -- custom hook
    if self.hookmousepressed then
        self.hookmousepressed(x, y, button)
    end
end

function Gui3.Element:mousereleased(x, y, button)
    if self.scrolling[1] or self.scrolling[2] then
        self.scrolling[1] = false
        self.scrolling[2] = false

        self:updateRender()
    end

    self.exclusiveMouse = false
end

function Gui3.Element:wheelmoved(x, y)
    if self.hasScrollbar[2] and y ~= 0 then
        self.scroll[2] = self.scroll[2] - y*17
        self:limitScroll()
        self:updateRender()

        return true
    end

    -- scroll horizontally if there's no y scrolling
    if not self.hasScrollbar[2] and self.hasScrollbar[1] and y ~= 0 then
        self.scroll[1] = self.scroll[1] - y*17
        self:limitScroll()
        self:updateRender()

        return true
    end

    if self.hasScrollbar[1] and x ~= 0 then
        self.scroll[1] = self.scroll[1] - x*17
        self:limitScroll()
        self:updateRender()

        return true
    end
end

function Gui3.Element:moveToFront()
    if self.parent then
        if self.movesToFront then
            for i = 1, #self.parent.children do
                if self.parent.children[i] == self then
                    table.insert(self.parent.children, table.remove(self.parent.children, i))
                end
            end
        end

        self.parent:moveToFront()

        self:mouseRegionChanged()
        self.parent:updateRender()
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

    self:sizeChanged()
end

function Gui3.Element:positionChanged()
    self:mouseRegionChanged()
    self.parent:updateRender()
end

function Gui3.Element:sizeChanged()
    -- Update childBox
    if self.childPadding then
        self.childBox[1] = self.childPadding[1]
        self.childBox[2] = self.childPadding[2]
        self.childBox[3] = self.w-self.childPadding[1]-self.childPadding[3]
        self.childBox[4] = self.h-self.childPadding[2]-self.childPadding[4]
    else
        self.childBox[1] = 0
        self.childBox[2] = 0
        self.childBox[3] = self.w
        self.childBox[4] = self.h
    end

    -- Update canvas
    if not self.canvas or self.canvas:getWidth() ~= self.w or self.canvas:getHeight() ~= self.h then -- canvas isn't current anymore
        if self.w > 0 and self.h > 0 then -- but not 0 px wide or tall
            self.canvas = love.graphics.newCanvas(math.ceil(self.w), math.ceil(self.h))
        end
    end

    for _, child in ipairs(self.children) do
        if child.parentSizeChanged then
            child:parentSizeChanged()
        end
    end

    self:limitScroll()
    self:updateScrollbars()
    self:mouseRegionChanged()
    self:updateRender()
end

function Gui3.Element:mouseRegionChanged()
    local root = self:getRoot()

    if root.updateMouseRegions then
        root:updateMouseRegions()
    end
end

function Gui3.Element:getRoot()
    local el = self
    while el.parent do
        el = el.parent
    end

    return el
end

function Gui3.Element:updateRender()
    if not self.needReRender then
        self.needsReRender = true

        if self.parent then
            self.parent:updateRender()
        end
    end
end

function Gui3.Element:onAssign() end
