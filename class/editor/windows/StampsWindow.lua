local StampsWindow = class("StampWindow")

StampsWindow.x = 14
StampsWindow.y = 14
StampsWindow.width = 140
StampsWindow.height = 200
StampsWindow.maxButtonHeight = 4

function StampsWindow:initialize(editor)
    self.editor = editor
    self.level = self.editor.level

    self.element = Gui3.Box:new(self.x, self.y, StampsWindow.width, StampsWindow.height)
    self.element.draggable = true
    self.element.resizeable = true
    self.element.closeable = true
    self.element.scrollable = {true, true}
    self.element.title = "stamps"
    self.element.clip = true
    self.editor.canvas:addChild(self.element)

    self.element.background = {0.5, 0.5, 0.5}

    self.buttons = {}

    for _, tileMap in ipairs(self.level.tileMaps) do
        for _, stampMap in ipairs(tileMap.stampMaps) do
            local width = stampMap.width
            local height = stampMap.height

            local scale = 1/math.ceil(height/self.maxButtonHeight)

            local drawWidth = width*scale
            local drawHeight = height*scale

            local button = Gui3.Button:new(0, 0, {stampMap.name, function() self:drawStampMap(stampMap, width, height, scale) end}, true, 0, function() self:clickStampMap(stampMap) end, drawWidth*16, drawHeight*16+9)

            table.insert(self.buttons, button)
            self.element:addChild(button)
        end
    end

    self:arrangeButtons()

    self.element.sizeChanged = function()
        self:arrangeButtons()
    end
end

function StampsWindow:arrangeButtons()
    local x = 2
    local y = 2
    local maxHeight = 0

    for _, button in ipairs(self.buttons) do
        local width = button.w
        local height = button.h

        maxHeight = math.max(maxHeight, height)

        if x + width+2 > self.element:getInnerWidth() then
            x = 2
            y = y + maxHeight + 2
            maxHeight = 0
        end

        button.x = x
        button.y = y

        x = x + width + 2
    end
end

function StampsWindow:clickStampMap(stampMap)
    self.editor:setActiveStampMap(stampMap)
    self.editor:selectTool("stamp")
end

function StampsWindow:drawStampMap(stampMap, width, height, scale)
    love.graphics.scale(scale)
    stampMap:draw(1, 1, width, height, true)
    love.graphics.scale(1/scale)
end

return StampsWindow
