local tiles = {}

local templates = VAR("tileTemplates")

tiles[1] = {collision = templates.cube}
tiles[2] = {collision = templates.cube}
tiles[3] = {collision = templates.cube}
tiles[7] = {collision = templates.cube}

tiles[9] = {collision = templates.cube}
tiles[10] = {collision = templates.cube}
tiles[11] = {collision = templates.cube}

tiles[17] = templates.smallSlopeRight1
tiles[18] = templates.smallSlopeRight2

tiles[19] = templates.bigSlopeRight

tiles[25] = templates.smallSlopeLeft1
tiles[26] = templates.smallSlopeLeft2

tiles[27] = templates.bigSlopeLeft

tiles[35] = templates.bigSlopeLeftUpsideDown
tiles[38] = templates.bigSlopeRightUpsideDown

local stampMaps = {
    {
        name = "test",
        t = "simple",
        map = {
            {0, 10, 0},
            {10, 10, 10},
            {0, 10, 0},
        }
    },
    
    {
        name = "ground",
        type = "quads",
        map = {
            {1, 2, 3},
            {9, 10, 11},
            {9, 10, 11},
        },
        paddings = {1, 1, 1, 1}, -- clockwise from top (like in css)
    }
}

local props = {
    tileSize = 16,
    tileMap = "tiles.png",
    tiles = tiles,
    stampMaps = stampMaps,
}

return props
