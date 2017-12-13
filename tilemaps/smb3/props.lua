local tiles = {}

tiles[1193] = {collision = true}
tiles[1120] = {collision = true}
tiles[1121] = {collision = true}
tiles[1194] = {collision = true}

tiles[1338] = {collision = true, partialCollision = true, mesh = {
    { 0,  0},
    {16,  8},
    {16, 16},
    { 0, 16}
}}
tiles[1339] = {collision = true, partialCollision = true, mesh = {
    { 0,  8},
    {16, 16},
    { 0, 16}
}}
tiles[1340] = {collision = true, partialCollision = true, mesh = {
    { 0,  0},
    {16, 16},
    { 0, 16},
}}

local props = {
    tileSize = 16,
    collisionMap = "collision.png",
    tileMap = "tiles.png",
    tiles = tiles
}

return props
