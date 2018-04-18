StampMap = class("StampMap")

function StampMap.fromSelection(editor, selection)
    local tiles = selection.tiles

    xl, yt, xr, yb = math.huge, math.huge, 0, 0

    for i = 1, #tiles do
        local x, y = tiles[i][1], tiles[i][2]

        if editor.level:inMap(x, y) and editor.level:getTile(x, y) then
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

        if editor.level:inMap(x, y) and editor.level:getTile(x, y) then
            stampMap[x-xl+1][y-yt+1] = editor.level.map[x][y]
        end
    end

    return StampMap:new(stampMap, width, height), xl, yt
end

function StampMap:initialize(map, w, h)
    self.map = map
    self.width = w
    self.height = h
end