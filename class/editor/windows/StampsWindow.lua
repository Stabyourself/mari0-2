local StampsWindow = class("StampWindow")

StampsWindow.x = 14
StampsWindow.y = 14
StampsWindow.width = 140
StampsWindow.height = 200
StampsWindow.maxButtonHeight = 4

function StampsWindow:initialize(editor)
    self.editor = editor
    self.level = self.editor.level

    self.element = Gui3.Box:new(self.x, self.y, self.width, self.height)
    self.element:setDraggable(true)
    self.element.resizeable = true
    self.element.closeable = true
    self.element.scrollable = {true, true}
    self.element.title = "stamps"
    self.editor.canvas:addChild(self.element)

    self.element.background = {0.5, 0.5, 0.5}

    for _, tileMap in ipairs(self.level.tileMaps) do
        for _, stampMap in ipairs(tileMap.stampMaps) do
            local width = stampMap.width
            local height = stampMap.height

            local scale = 1/math.ceil(height/self.maxButtonHeight)

            local drawWidth = width*scale
            local drawHeight = height*scale

            local text = Gui3.Text:new(stampMap.name, 0, 0)
            local subDraw = Gui3.SubDraw:new(function()
                self:drawStampMap(stampMap, width, height, scale)
            end,
            0, 0, drawWidth*16, drawHeight*16)

            subDraw.noMouseEvents = true

            local button = Gui3.ComponentButton:new(0, 0, {
                text,
                subDraw,
            }, true, 0, function() self:clickStampMap(stampMap) end)

            self.element:addChild(button)
        end
    end

    self.element.autoArrangeChildren = true
    self.element:sizeChanged()
    self.element:mouseRegionChanged()
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
