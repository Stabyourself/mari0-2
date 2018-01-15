local tiles = {}

local templates = VAR("tileTemplates")

tiles[1] = templates.cube
tiles[2] = templates.cube
tiles[3] = templates.cube
tiles[7] = templates.cube

tiles[9] = templates.cube
tiles[10] = templates.cube
tiles[11] = templates.cube

tiles[17] = templates.smallSlopeRight1
tiles[18] = templates.smallSlopeRight2

tiles[19] = templates.bigSlopeRight

tiles[25] = templates.smallSlopeLeft1
tiles[26] = templates.smallSlopeLeft2

tiles[27] = templates.bigSlopeLeft

tiles[35] = templates.bigSlopeLeftUpsideDown
tiles[38] = templates.bigSlopeRightUpsideDown

local props = {
    tileSize = 16,
    tileMap = "tiles.png",
    tiles = tiles
}

return props
