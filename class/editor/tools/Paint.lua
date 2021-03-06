local Paint = class("Editor.Paint")

function Paint:initialize(editor)
    self.editor = editor

    self.level = self.editor.level
    self.penDown = false
    self.tileI = 1
    self.tile = self.level.tileMaps[1].tiles[1]
end

function Paint:update()
    if self.penDown then
        local x, y = self.level:mouseToCoordinate()

        if x ~= self.lastX or y ~= self.lastY then
            local layer = self.editor.activeLayer

            if not layer:inMap(x, y) then
                layer:expandTo(x, y)
            end

            local tiles

            if not self.lastX then
                tiles = {{x, y}}
            else
                tiles = tilesInLine(self.lastX, self.lastY, x, y)
            end

            -- intersect with selection if there is one
            if self.editor.selection then
                tiles = intersectTiles(tiles, self.editor.selection.tiles)
            end

            for _, tile in ipairs(tiles) do
                if layer.map[tile[1]][tile[2]].tile ~= self.tile then -- don't set the same tile
                    layer:setCoordinate(tile[1], tile[2], self.tile)
                end
            end

            self.lastX = x
            self.lastY = y
        end
    end
end

function Paint:draw()
    local coordX, coordY = self.level:mouseToCoordinate()

    if controls3.cmdDown("editor.line") and self.lastX then -- line
        love.graphics.setColor(1, 1, 1, 0.5)

        local tiles = tilesInLine(self.lastX, self.lastY, coordX, coordY)

        for _, tile in ipairs(tiles) do
            local worldX, worldY = self.level:coordinateToWorld(tile[1]-1, tile[2]-1)
            self.tile:draw(worldX, worldY)
        end

        love.graphics.setColor(1, 1, 1)

        self.editor:drawSizeHelp(coordX-self.lastX, coordY-self.lastY, ",")

    else -- regular painting
        love.graphics.setColor(1, 1, 1, 0.5)

        local worldX, worldY = self.level:coordinateToWorld(coordX-1, coordY-1)
        self.tile:draw(worldX, worldY)

        love.graphics.setColor(1, 1, 1)
    end
end

function Paint:mousepressed(x, y, button)
    if (button == 1 and controls3.cmdDown("editor.pipette")) or button == 3 then
        self.editor:pipette(x, y)

    elseif button == 1 and controls3.cmdDown("editor.line") and self.lastX then
        local coordX, coordY = self.level:cameraToCoordinate(x, y)

        local layer = self.editor.activeLayer

        if not layer:inMap(coordX, coordY) then
            layer:expandTo(coordX, coordY)
        end

        local tiles = tilesInLine(self.lastX, self.lastY, coordX, coordY)

        -- intersect with selection if there is one
        if self.editor.selection then
            tiles = intersectTiles(tiles, self.editor.selection.tiles)
        end

        for _, tile in ipairs(tiles) do
            layer:setCoordinate(tile[1], tile[2], self.tile)
        end

        self.editor:mapChanged()

        self.lastX = coordX
        self.lastY = coordY

    elseif button == 1 then
        self.penDown = true

        self.lastX = nil
        self.lastY = nil
    end

    return true
end

function Paint:mousereleased(x, y, button)
    if self.penDown then
        self.penDown = false

        self.editor:mapChanged()
    end
end

return Paint
