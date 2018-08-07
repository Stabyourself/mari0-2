local tiles = {}

local templates = VAR("tileTemplates")

--collisions
local cubes = {1, 2, 3, 9, 10, 11}

for _, v in ipairs(cubes) do
    tiles[v] = {collision = templates.cube}
end

-- top colliding things
local topThings = {7, 17, 18, 19, 20, 21, 22, 41, 42, 43, 44, 45, 46}

for _, v in ipairs(topThings) do
    tiles[v] = {
        collision = templates.cube,
        exclusiveCollision = 1,
    }
end

local stampMaps = {
    {
        name = "ground",
        type = "quads",
        map = {
            {1, 2, 3},
            {9, 10, 11},
        },
        paddings = {1, 1, 0, 1}, -- clockwise from top (like in css)
    },

    {
        name = "cloud",
        type = "quads",
        map = {
            {4, 5, 6},
            {12, 13, 14},
        },
        paddings = {2, 1, 0, 1}, -- clockwise from top (like in css)
    }
}

local props = {
    tileSize = 16,
    tileMap = "tiles.png",
    tiles = tiles,
    stampMaps = stampMaps
}

return props
