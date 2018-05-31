local Gui3 = ...
Gui3.Box = class("Gui3.Box", Gui3.Element)

Gui3.Box.movesToTheFront = true

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
end

function Gui3.Box:update(dt, x, y, mouseBlocked, absX, absY)
    local ret = Gui3.Element.update(self, dt, x, y, mouseBlocked, absX, absY)

    if self.draggable then
        self.sizeMin[1] = 19
        self.sizeMin[2] = 29

        self.childBox[1] = 3
        self.childBox[2] = 12
        self.childBox[3] = self.w-6
        self.childBox[4] = self.h-16
    else
        self.sizeMin[1] = 17
        self.sizeMin[2] = 19

        self.childBox[1] = 2
        self.childBox[2] = 3
        self.childBox[3] = self.w-4
        self.childBox[4] = self.h-6
    end

    return ret
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
        love.graphics.intersectScissor(
            (self.absPos[1]+3)*VAR("scale"),
            (self.absPos[2]+2)*VAR("scale"),
            (self.w-16)*VAR("scale"),
            8*VAR("scale")
        )

        love.graphics.print(self.title, 3, 2)

        love.graphics.setScissor(scissorX, scissorY, scissorW, scissorH)
    end

    if self.closeable then
        local closeImg = self.gui.img.boxClose
        if self.closing then
            closeImg = self.gui.img.boxCloseActive
        elseif self:closeCollision(self.mouse[1], self.mouse[2]) then
            closeImg = self.gui.img.boxCloseHover
        end

        love.graphics.draw(closeImg, self.w-12, 2)
    end

    Gui3.Element.draw(self, level)

    if self.resizeable then
        local resizeImg = self.gui.img.boxResize
        if self.resizing then
            resizeImg = self.gui.img.boxResizeActive
        elseif self:resizeCornerCollision(self.mouse[1], self.mouse[2]) then
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
    return not self.mouseBlocked and x >= 0 and x < self.w and y >= 0 and y < 12
end

function Gui3.Box:resizeCornerCollision(x, y)
    return not self.mouseBlocked and x >= self.w-11 and x < self.w-3 and y >= self.h-12 and y < self.h-4
end

function Gui3.Box:closeCollision(x, y)
    return not self.mouseBlocked and x >= self.w-12 and x < self.w-3 and y >= 2 and y < 11
end

function Gui3.Box:collision(x, y)
    return not self.mouseBlocked and x >= 0 and x < self.w and y >= 0 and y < self.h
end

function Gui3.Box:mousepressed(x, y, button)
    -- Check resize before the rest because reasons
    if self.resizeable and self:resizeCornerCollision(x, y) then
        self.resizing = true
        self.resizePos[1] = self.w-x
        self.resizePos[2] = self.h-y

    elseif self.closeable and self:closeCollision(x, y) then
        self.closing = true

    elseif self.draggable and self:titleBarCollision(x, y) then
        self.dragging = true
        self.dragPos[1] = x
        self.dragPos[2] = y

    end

    return Gui3.Element.mousepressed(self, x, y, button)
end

function Gui3.Box:mousereleased(x, y, button)
    self.dragging = false
    self.resizing = false

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
    if self.autoArrangeChildren then
        self:arrangeChildren()
    end
end

function Gui3.Box:arrangeChildren()
    local offX = self.offX or 2
    local offY = self.offY or 2

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
