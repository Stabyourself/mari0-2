local Gui3 = ...
Gui3.Box = class("Gui3.Box", Gui3.Element)

Gui3.Box.movesToTheFront = true

Gui3.Box.childPaddingDraggable = {3, 12, 3, 4}
Gui3.Box.childPaddingStatic = {2, 3, 2, 3}
Gui3.Box.sizeMinDraggable = {19, 29}
Gui3.Box.sizeMinStatic = {17, 19}

function Gui3.Box:initialize(x, y, w, h)
    Gui3.Element.initialize(self, x, y, w, h)

    self.background = {0, 0, 0, 0}
    self.backgroundQuad = love.graphics.newQuad(0, 0, 4, 4, 4, 4)

    self.children = {}

    self.posMin[1] = -3
    self.posMin[2] = -2

    self.posMax[1] = -3
    self.posMax[2] = -4

    self.childBox = {2, 3, self.w-4, self.h-6}

    self:setDraggable(false)
end

function Gui3.Box:setDraggable(draggable)
    self.draggable = draggable

    if self.draggable then
        self.childPadding = self.childPaddingDraggable
        self.sizeMin = self.sizeMinDraggable
    else
        self.childPadding = self.childPaddingStatic
        self.sizeMin = self.sizeMinStatic
    end

    self.childBox[1] = self.childPadding[1]
    self.childBox[2] = self.childPadding[2]
    self.childBox[3] = self.w-self.childPadding[1]-self.childPadding[3]
    self.childBox[4] = self.h-self.childPadding[2]-self.childPadding[4]
end

function Gui3.Box:draw(level)
    Gui3.Element.translate(self)

    if type(self.background) == "table" then
        love.graphics.setColor(self.background)
        love.graphics.rectangle("fill", self.childBox[1], self.childBox[2], self.childBox[3], self.childBox[4])
    elseif type(self.background) == "userdata" then
        self.backgroundQuad:setViewport(self.scroll[1]%4, self.scroll[2]%4, self.childBox[3], self.childBox[4])
        self.background:setWrap("repeat", "repeat")

        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(self.background, self.backgroundQuad, self.childBox[1], self.childBox[2])
    end


    love.graphics.setColor(1, 1, 1)

    -- Border
    local borderImg = self.gui.img.box
    local quad = Gui3.boxQuad
    if self.draggable then
        borderImg = self.gui.img.boxTitled
        quad = Gui3.titledBoxQuad
    end

    Gui3.drawBox(borderImg, quad, 0, 0, self.w, self.h)

    if self.title then
        local scissorX, scissorY, scissorW, scissorH = love.graphics.getScissor()
        -- love.graphics.intersectScissor(
        --     (self.absPos[1]+3)*VAR("scale"),
        --     (self.absPos[2]+2)*VAR("scale"),
        --     (self.w-16)*VAR("scale"),
        --     8*VAR("scale")
        -- )

        love.graphics.print(self.title, 3, 2)

        love.graphics.setScissor(scissorX, scissorY, scissorW, scissorH)
    end

    if self.closeable then
        local closeImg = self.gui.img.boxClose
        if self.closing then
            closeImg = self.gui.img.boxCloseActive
        elseif self.mouse[1] and self:closeCollision(self.mouse[1], self.mouse[2]) then
            closeImg = self.gui.img.boxCloseHover
        end

        love.graphics.draw(closeImg, self.w-12, 2)
    end

    Gui3.Element.draw(self, level)

    if self.resizeable then
        local resizeImg = self.gui.img.boxResize
        if self.resizing then
            resizeImg = self.gui.img.boxResizeActive
        elseif self.mouse[1] and self:resizeCornerCollision(self.mouse[1], self.mouse[2]) then
            resizeImg = self.gui.img.boxResizeHover
        end

        local x, y = self.w-11, self.h-12
        if not self.draggable then
            x = x + 1
            y = y + 1
        end

        love.graphics.draw(resizeImg, x, y)
    end

    Gui3.Element.unTranslate(self)
end

function Gui3.Box:titleBarCollision(x, y)
    return x >= 0 and x < self.w and y >= 0 and y < 12
end

function Gui3.Box:resizeCornerCollision(x, y)
    return x >= self.w-11 and x < self.w-3 and y >= self.h-12 and y < self.h-4
end

function Gui3.Box:closeCollision(x, y)
    return x >= self.w-12 and x < self.w-3 and y >= 2 and y < 11
end

function Gui3.Box:collision(x, y)
    return x >= 0 and x < self.w and y >= 0 and y < self.h
end

function Gui3.Box:mousepressed(x, y, button)
    -- Check resize before the rest because reasons
    if self.resizeable and self:resizeCornerCollision(x, y) then
        self.resizing = true
        self.resizePos[1] = self.w-x
        self.resizePos[2] = self.h-y

        self.exclusiveMouse = true

    elseif self.closeable and self:closeCollision(x, y) then
        self.closing = true

    elseif self.draggable and self:titleBarCollision(x, y) then
        self.dragging = true
        self.dragPos[1] = x
        self.dragPos[2] = y
        self.dragStart[1] = self.x
        self.dragStart[2] = self.y

        self.exclusiveMouse = true
    end

    return Gui3.Element.mousepressed(self, x, y, button)
end

function Gui3.Box:mousereleased(x, y, button)
    self.dragging = false
    self.resizing = false
    self.exclusiveMouse = false

    if self.closing then
        if self:closeCollision(x, y) then
            self.parent:removeChild(self)
        else
            self.closing = false
        end
    end

    Gui3.Element.mousereleased(self, x, y, button)
end

function Gui3.Box:sizeChanged()
    Gui3.Element.sizeChanged(self)

    if self.autoArrangeChildren then
        self:arrangeChildren()
    end
end

function Gui3.Box:arrangeChildren()
    local offX = self.offX or 1
    local offY = self.offY or 1

    local x = offX
    local y = offY
    local maxHeight = 0

    for _, child in ipairs(self.children) do
        local width = child.w
        local height = child.h

        maxHeight = math.max(maxHeight, height)

        if x ~= offX and x + width+2 > self:getInnerWidth() then
            x = offX
            y = y + maxHeight + offY
            maxHeight = 0
        end

        child.x = x
        child.y = y

        x = x + width + offX
    end
end
