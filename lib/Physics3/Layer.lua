local Cell = require((...):gsub('%.Layer$', '') .. ".Cell")
Layer = class("Layer")

function Layer:initialize(world, x, y, width, height, map)
    self.world = world
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self.xOffset = 0
    self.yOffset = 0

    self.movement = false
    self.movementTimer = 0

    self.map = map or {}
    self.spriteBatches = {}

    self.viewport = {}
end

function Layer:update(dt)
    if self.movement == "sinethefuckout" then
        self.movementTimer = self.movementTimer + dt

        self.yOffset = math.sin(self.movementTimer)*8
    end
end

function Layer:setBatchCoordinate(x, y, tile)
    if tile.animated then
        if not self.spriteBatches[tile] then
            self.spriteBatches[tile] = love.graphics.newSpriteBatch(tile.img)
        end

        local i = self.spriteBatches[tile]:add(tile.quad, (x-1)*16, (y-1)*16)

        self.batchMap[x][y] = {spriteBatch=self.spriteBatches[tile], i=i}
    else
        if not self.spriteBatches[tile.tileMap] then
            self.spriteBatches[tile.tileMap] = love.graphics.newSpriteBatch(tile.tileMap.img)
        end

        local i = self.spriteBatches[tile.tileMap]:add(tile.quad, (x-1)*16, (y-1)*16)

        self.batchMap[x][y] = {spriteBatch=self.spriteBatches[tile.tileMap], i=i}
    end
end

function Layer:buildSpriteBatch(xStart, yStart)
    for _, spriteBatch in pairs(self.spriteBatches) do
        spriteBatch:clear()
    end

    local xEnd = xStart + math.ceil((self.world.camera.w+16)/self.world.camera.scale/16)
    local yEnd = yStart + math.ceil((self.world.camera.h+16)/self.world.camera.scale/16)

    local w = xEnd-xStart+1
    local h = yEnd-yStart+1

    -- Adjust the tiles that are actually checked for performance
    self.viewport[1] = math.clamp(xStart, self:getXStart(), self:getXEnd())
    self.viewport[2] = math.clamp(yStart, self:getYStart(), self:getYEnd())
    self.viewport[3] = math.clamp(xEnd, self:getXStart(), self:getXEnd())
    self.viewport[4] = math.clamp(yEnd, self:getYStart(), self:getYEnd())

    self.batchMap = {}
    for x = self.viewport[1], self.viewport[3] do
        self.batchMap[x] = {}

        for y = self.viewport[2], self.viewport[4] do
            local tile = self:getTile(x, y)

            if tile then
                self:setBatchCoordinate(x, y, tile)
            end
        end
    end
end

function Layer:draw()
    -- check if spriteBatch is outdated
    local xStart, yStart = self.world:cameraToCoordinate(-16, -16)

    if xStart ~= self.spriteBatchX or yStart ~= self.spriteBatchY then
        if VAR("debug").reSpriteBatchLayers then
            print("SpriteBatching layer!")
        end

        self.spriteBatchX = xStart
        self.spriteBatchY = yStart

        self:buildSpriteBatch(xStart, yStart)
    end


    local x = math.ceil(self.xOffset)
    local y = math.ceil(self.yOffset)

    -- draw the spritebatch
    for _, spriteBatch in pairs(self.spriteBatches) do
        love.graphics.draw(spriteBatch)
    end
end

function Layer:checkCollision(x, y, obj, vector)
    x = x - self.xOffset
    y = y - self.yOffset

    local cellX, cellY = self.world:worldToCoordinate(x, y)

    if self:inMap(cellX, cellY) then
        local cell = self:getCell(cellX, cellY)
        local tile = cell.tile

        if tile then
            local inCellX = x%16
            local inCellY = y%16

            if tile:checkCollision(inCellX, inCellY, obj, vector, cellX, cellY) then
                return cell
            end
        end
    end
end

function Layer:getXStart()
    return self.x+1
end

function Layer:getYStart()
    return self.y+1
end

function Layer:getXEnd()
    return self.x+self.width
end

function Layer:getYEnd()
    return self.y+self.height
end

function Layer:debugDraw()
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle(
        "line",
        self.x*16-.5+math.ceil(self.xOffset),
        self.y*16-.5+math.ceil(self.yOffset),
        self.width*16+1,
        self.height*16+1
    )
    love.graphics.setColor(1, 1, 1)
end

function Layer:getCell(x, y)
    return self.map[x-self.x][y-self.y]
end

function Layer:getTile(x, y)
    return self.map[x-self.x][y-self.y].tile
end

function Layer:setCoordinate(x, y, tile)
    self.map[x-self.x][y-self.y].tile = tile

    local batch = self.batchMap[x] and self.batchMap[x][y]

    if batch then
        batch.spriteBatch:set(batch.i, 0, 0, 0, 0, 0)
    end

    if tile then
        if  x >= self.viewport[1] and x <= self.viewport[3] and
            y >= self.viewport[2] and y <= self.viewport[4] then
            self:setBatchCoordinate(x, y, tile)
        end
    end
end

function Layer:optimizeSize() -- cuts a layer to its content and moves it instead
    -- left
    local x = self:getXStart()
    local found = false

    repeat
        for y = self:getYStart(), self:getYEnd() do

            if self:getTile(x, y) then
                found = true
            end
        end

        x = x + 1
    until found or x > self:getXEnd()

    x = x - 1

    if x > self:getXStart() then
        -- remove from the left
        local toRemove = x-self:getXStart()

        for i = 1, toRemove do
            table.remove(self.map, 1)
        end

        self.x = self.x + toRemove
        self.width = self.width - toRemove
    end

    -- right
    local x = self:getXEnd()
    local found = false

    repeat
        for y = self:getYStart(), self:getYEnd() do

            if self:getTile(x, y) then
                found = true
            end
        end

        x = x - 1
    until found or x < self:getXStart()

    x = x + 1

    if x < self:getXEnd() then
        local toRemove = self:getXEnd() - x

        for i = 1, toRemove do
            table.remove(self.map)
        end

        self.width = self.width - toRemove
    end

    -- up
    local y = self:getYStart()
    local found = false

    repeat
        for x = self:getXStart(), self:getXEnd() do

            if self:getTile(x, y) then
                found = true
            end
        end

        y = y + 1
    until found or y > self:getYEnd()

    y = y - 1

    if y > self:getYStart() then
        -- remove from the left
        local toRemove = y-self:getYStart()

        for i = 1, toRemove do
            for x = 1, self.width do
                table.remove(self.map[x], 1)
            end
        end

        self.y = self.y + toRemove
        self.height = self.height - toRemove
    end

    -- down
    local y = self:getYEnd()
    local found = false

    repeat
        for x = self:getXStart(), self:getXEnd() do

            if self:getTile(x, y) then
                found = true
            end
        end

        y = y - 1
    until found or y < self:getYStart()

    y = y + 1

    if y < self:getYEnd() then
        -- remove from the left
        local toRemove = self:getYEnd() - y

        for i = 1, toRemove do
            for x = 1, self.width do
                table.remove(self.map[x])
            end
        end

        self.height = self.height - toRemove
    end
end

function Layer:inMap(x, y)
    return x > self.x and x <= self.x+self.width and y > self.y and y <= self.y+self.height
end

function Layer:getFloodArea(startX, startY) -- Based off https://github.com/Yonaba/FloodFill/blob/master/floodfill/floodstackscanline.lua (which seems to be based off lodev?)
    local targetTile = self:getTile(startX, startY)

    local tileLookupTable = {}
    for tx = 1, self.width do
        tileLookupTable[tx+self.x] = {}
    end

	local spanLeft, spanRight

    local tileTable = {}
    stack = {{startX, startY}}

    while #stack > 0 do
        local p = table.remove(stack)

		local x, y = p[1], p[2]

		while ((y >= self:getYStart()) and self:getTile(x, y) == targetTile) do -- go to the highest possible point
			y = y - 1
		end
		y = y + 1
		spanLeft, spanRight = false, false

        while (y <= self:getYEnd() and self:getTile(x, y) == targetTile) and not tileLookupTable[x][y] do -- walk vertically down
            table.insert(tileTable, {x, y})
            tileLookupTable[x][y] = true

            if x > self:getXStart() then -- see if we wanna check out that sweet, sexy, vertical line to the left
                if (not spanLeft and self:getTile(x-1, y) == targetTile) and not tileLookupTable[x-1][y] then
                    table.insert(stack, {x-1, y})
                    spanLeft = true
                elseif (spanLeft and self:getTile(x-1, y) ~= targetTile)then
                    spanLeft = false
                end
            end

            if x < self:getXEnd() then -- and same with right
                if (not spanRight and self:getTile(x+1, y) == targetTile) and not tileLookupTable[x+1][y] then
                    table.insert(stack, {x+1, y})
                    spanRight = true
                elseif (spanRight and self:getTile(x+1, y) ~= targetTile) then
                    spanRight = false
                end
            end

			y = y + 1
		end
	end

    return tileTable
end

function Layer:expandTo(x, y)
    x, y = x-self.x, y-self.y

    if x <= 0 then
        local newColumns = 1-x

        for i = 1, newColumns do
            local emptyRow = {}

            for ly = 1, self.height do
                table.insert(emptyRow, Cell:new(nil))
            end

            table.insert(self.map, 1, emptyRow)
        end

        self.width = self.width + newColumns
        self.x = self.x - newColumns
    end

    if x > self.width then
        local newColumns = x-self.width

        for i = 1, newColumns do
            local emptyRow = {}
            for ly = 1, self.height do
                table.insert(emptyRow, Cell:new(nil))
            end

            table.insert(self.map, emptyRow)
        end

        self.width = self.width + newColumns
    end

    if y <= 0 then
        local newRows = 1-y

        for i = 1, newRows do
            for lx = 1, self.width do
                table.insert(self.map[lx], 1, Cell:new(nil))
            end
        end

        self.height = self.height + newRows
        self.y = self.y - newRows
    end

    if y > self.height then
        local newRows = y-self.height

        for i = 1, newRows do
            for lx = 1, self.width do
                table.insert(self.map[lx], Cell:new(nil))
            end
        end

        self.height = self.height + newRows
    end
end

return Layer
