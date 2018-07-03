local StampMap = class("StampMap")

function StampMap.fromSelection(editor, selection)
    local tiles = selection.tiles

    xl, yt, xr, yb = math.huge, math.huge, 0, 0

    for i = 1, #tiles do
        local x, y = tiles[i][1], tiles[i][2]

        if editor.activeLayer:inMap(x, y) and editor.activeLayer:getTile(x, y) then
            if x < xl then
                xl = x
            end

            if x > xr then
                xr = x
            end

            if y < yt then
                yt = y
            end

            if y > yb then
                yb = y
            end
        end
    end

    local width = xr-xl+1
    local height = yb-yt+1

    local stampMap = {}

    for x = 1, width do
        stampMap[x] = {}
    end

    for _, tile in ipairs(tiles) do
        local x, y = tile[1], tile[2]

        if editor.activeLayer:inMap(x, y) and editor.activeLayer:getTile(x, y) then
            stampMap[x-xl+1][y-yt+1] = editor.activeLayer:getTile(x, y)
        end
    end

    return StampMap:new(stampMap, width, height), xl, yt
end

function StampMap:initialize(map, w, h, type, name, paddings)
    self.map = map
    self.width = w
    self.height = h
    self.type = type or "simple"
    self.name = name or ""
    self.paddings = paddings or {}
end

function StampMap:draw(x, y, w, h, uncentered)
    if self.type == "simple" then
        if not uncentered then
            local offsetX, offsetY = self:getOffset()

            x = math.floor(x + offsetX+1)
            y = math.floor(y + offsetY+1)
        end

        for qx = 1, self.width do
            for qy = 1, self.height do
                local tileX = (x+qx-2)*16
                local tileY = (y+qy-2)*16

                local tile = self.map[qx] and self.map[qx][qy]

                if tile then
                    tile:draw(tileX, tileY)
                end
            end
        end
    else
        local quadStampMap = self:getQuadStampMap(w, h)

        for qx = 1, w do
            for qy = 1, h do
                local tile = quadStampMap[qx][qy]

                if tile then
                    tile:draw((x+qx-2)*16, (y+qy-2)*16)
                end
            end
        end
    end
end

function StampMap:stamp(layer, x, y, w, h)
    if self.type == "simple" then
        local offsetX, offsetY = self:getOffset()

        x = math.floor(x + offsetX)
        y = math.floor(y + offsetY)

        layer:expandTo(x+1, y+1)
        layer:expandTo(x+self.width, y+self.height)

        for qx = 1, self.width do
            for qy = 1, self.height do
                layer:setCoordinate(x+qx, y+qy, self.map[qx][qy])
            end
        end
    elseif self.type == "quads" then
        if w < 1 then
            x = x + w-1
            w = -w+2
        end

        if h < 1 then
            y = y + h-1
            h = -h+2
        end

        local quadStampMap = self:getQuadStampMap(w, h)

        -- expand the layer as necessary
        layer:expandTo(x, y)
        layer:expandTo(x+w-1, y+h-1)

        for lx = 1, w do
            for ly = 1, h do
                layer:setCoordinate(x+lx-1, y+ly-1, quadStampMap[lx][ly])
            end
        end
    end
end

function StampMap:getQuadStampMap(w, h)
    local paddings = self.paddings

    local map = {}

    for i = 1, w do
        map[i] = {}
    end

    local middleXnum = #self.map-paddings[2]-paddings[4]
    local middleYnum = #self.map[1]-paddings[1]-paddings[3]

    -- Bottom right
    for lx = math.max(1, w-paddings[2]+1), w do
        for ly = h-paddings[3]+1, h do
            local offsetX = (lx-w-1)%paddings[2]
            local offsetY = (ly-h-1)%paddings[3]

            map[lx][ly] = self.map[1+self.width-paddings[2]+offsetX][1+self.height-paddings[3]+offsetY]
        end
    end

    if paddings[2] + paddings[4] < #self.map then
        -- Bottom
        for lx = 1+paddings[4], w-paddings[2] do
            for ly = h-paddings[3]+1, h do
                local offsetX = (lx-1)%middleXnum
                local offsetY = (ly-h-1)%paddings[3]

                map[lx][ly] = self.map[1+paddings[4]+offsetX][1+self.height-paddings[3]+offsetY]
            end
        end

        -- Center
        for lx = paddings[4]+1, w-paddings[2] do
            for ly = 1+paddings[1], h-paddings[3] do
                local offsetX = (lx-1)%middleXnum
                local offsetY = (ly-1)%middleYnum

                map[lx][ly] = self.map[1+paddings[4]+offsetX][1+paddings[1]+offsetY]
            end
        end

        -- Top
        for lx = 1+paddings[4], w-paddings[2] do
            for ly = 1, paddings[1] do
                local offsetX = (lx-1)%middleXnum
                local offsetY = (ly-1)%paddings[1]

                map[lx][ly] = self.map[1+paddings[4]+offsetX][1+offsetY]
            end
        end
    end

    -- Bottom left
    for lx = 1, math.min(w, paddings[4]) do
        for ly = h-paddings[3]+1, h do
            local offsetX = (lx-1)%paddings[4]
            local offsetY = (ly-h-1)%paddings[3]

            map[lx][ly] = self.map[1+offsetX][1+self.height-paddings[3]+offsetY]
        end
    end

    -- Right
    for lx = math.max(1, w-paddings[2]+1), w do
        for ly = 1+paddings[1], h-paddings[3] do
            local offsetX = (lx-w-1)%paddings[2]
            local offsetY = (ly-1)%middleYnum

            map[lx][ly] = self.map[1+self.width-paddings[2]+offsetX][1+paddings[1]+offsetY]
        end
    end

    -- Left
    for lx = 1, math.min(w, paddings[4]) do
        for ly = 1+paddings[1], h-paddings[3] do
            local offsetX = (lx-1)%paddings[4]
            local offsetY = (ly-1)%middleYnum

            map[lx][ly] = self.map[1+offsetX][1+paddings[1]+offsetY]
        end
    end

    -- Top right
    for lx = math.max(1, w-paddings[2]+1), w do
        for ly = 1, paddings[1] do
            local offsetX = (lx-w-1)%paddings[2]
            local offsetY = (ly-1)%paddings[1]

            map[lx][ly] = self.map[1+self.width-paddings[2]+offsetX][1+offsetY]
        end
    end

    -- Top left
    for lx = 1, math.min(w, paddings[4]) do
        for ly = 1, paddings[1] do
            local offsetX = (lx-1)%paddings[4]
            local offsetY = (ly-1)%paddings[1]

            map[lx][ly] = self.map[1+offsetX][1+offsetY]
        end
    end

    return map
end

function StampMap:getOffset()
    return -self.width/2-.5, -self.height/2-.5
end

return StampMap
