local tiles = {}

local templates = VAR("tileTemplates")

tiles[1] = {
    collision = templates.cube,
    img = "coinblock1.png",
    delays = {8/60},
    holdsItems = true,
    defaultItem = "coin", -- ?
    turnsInto = 4,
}

tiles[2] = {
    collision = templates.cube,
    img = "brick1.png",
    delays = {8/60},
    holdsItems = true,
}

local cubes = {3, 4, 9, 10, 11, 12, 17, 18, 19, 20}

for _, v in ipairs(cubes) do
    tiles[v] = {collision = templates.cube}
end

local stampMaps = {
    {
        name = "pipe",
        type = "quads",
        map = {
            {9, 10},
            {17, 18},
        },
        paddings = {1, 0, 0, 0}, -- clockwise from top (like in css)
    }
}

local props = {
    tileSize = 16,
    tileMap = "tiles.png",
    tiles = tiles,
    stampMaps = stampMaps
}

return props
