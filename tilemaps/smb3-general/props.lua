local tiles = {}

local templates = VAR("tileTemplates")

tiles[1] = {
    collision = templates.cube,
    img = "coinblock1.png",
    delays = {8/60}
}

local props = {
    tileSize = 16,
    tileMap = "tiles.png",
    tiles = tiles
}

return props
