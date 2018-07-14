local tiles = {}

local templates = VAR("tileTemplates")

tiles[1] = {
    img = "coin.png",
    delays = {8/60},
    coin = true,
}

tiles[2] = {
    collision = templates.cube,
    img = "coinblock.png",
    delays = {8/60},
    holdsItems = true,
    defaultItem = "coin", -- ?
    turnsInto = 4,
}

tiles[3] = {
    collision = templates.cube,
    img = "brick.png",
    delays = {8/60},
    holdsItems = true,
}


tiles[7] = {
    img = "smm_thing_1.png",
    delays = {8/60},
}

tiles[8] = {
    collision = templates.cube,
    nonPortalable = true,
    exclusiveCollision = 2,
    img = "smm_thing_2.png",
    delays = {8/60},
}

tiles[15] = {
    img = "smm_thing_3.png",
    delays = {8/60},
}

tiles[16] = {
    collision = templates.cube,
    nonPortalable = true,
    exclusiveCollision = 2,
    img = "smm_thing_4.png",
    delays = {8/60},
}

local cubes = {4, 5, 9, 10, 11, 12, 17, 18, 19, 20}

for _, v in ipairs(cubes) do
    tiles[v] = {collision = templates.cube}
end

tiles[3].nonPortalable = {false, true, false, true}

local stampMaps = {
    {
        name = "pipe",
        type = "quads",
        map = {
            {9, 10},
            {17, 18},
        },
        paddings = {1, 0, 0, 0}, -- clockwise from top (like in css)
    },

    {
        name = "1way",
        type = "simple",
        map = {
            {7, 8},
            {15, 16},
        },
    }
}

local props = {
    tileSize = 16,
    tileMap = "tiles.png",
    tiles = tiles,
    stampMaps = stampMaps
}

return props
