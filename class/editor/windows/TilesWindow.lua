local TilesWindow = class("TilesWindow")

TilesWindow.x = 14
TilesWindow.y = 14
TilesWindow.width = 8*17+21
TilesWindow.height = 200
TilesWindow.tileWidth = 8
TilesWindow.tileHeight = 2

function TilesWindow:initialize(editor)
    self.editor = editor
    self.level = self.editor.level

    self.element = Gui3.Box:new(self.x, self.y, self.width, self.height)
    self.element:setDraggable(true)
    self.element.resizeable = true
    self.element.closeable = true
    self.element.scrollable = {true, true}
    self.element.title = "tiles"
    self.editor.canvas:addChild(self.element)

    self:goToMenu()
end

function TilesWindow:goToMenu()
    self.element:clearChildren()

    self.element.background = {0.5, 0.5, 0.5, 1}
    self.element.title = "tiles"

    -- populate element with a button for each tileMap
    self.reRenderFunctions = {}

    for i, tileMap in ipairs(self.level.tileMaps) do
        local thumb = tileMap.thumbImg or tileMap.img

        local text = Gui3.Text:new(tileMap.name, 0, 0)
        local tileGrid = Gui3.TileGrid:new(0, 0, tileMap, nil, true, 8, 2)

        local tileMapButton = Gui3.ComponentButton:new(
            0,
            0,
            {
                text,
                tileGrid,
            },
            true,
            0,
            function()
                self:goToTileMap(tileMap)
            end,
            self.tileWidth*17-1, self.tileHeight*17-1+9
        )

        self.element:addChild(tileMapButton)
    end

    self.element.autoArrangeChildren = true
    self.element:sizeChanged()
end

function TilesWindow:goToTileMap(tileMap)
    self.tileMap = tileMap

    self.element:clearChildren()
    self.element.title = tileMap.name

    self.element.background = self.editor.checkerboardImg

    local backButton = Gui3.TextButton:new(1, 1, "< back", true, 0, function() self:goToMenu() end)
    backButton.ignoreForParentSize = true
    self.element:addChild(backButton)

    self.tileGrid = Gui3.TileGrid:new(1, 16, self.tileMap,
        function(TileGrid, i)
            TileGrid:setSelected(i)

            self.editor:selectTile(self.tileMap.tiles[i])
        end
    )

    -- select tile if the tilemap is the same
    if tileMap == self.editor.tools.paint.tile.tileMap then -- select it
        self.tileGrid:setSelected(self.editor.tools.paint.tile.num)
    end


    self.element:addChild(self.tileGrid)
    self.element.autoArrangeChildren = false
    self.element:sizeChanged()
end

return TilesWindow
