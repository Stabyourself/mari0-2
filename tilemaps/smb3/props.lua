local tiles = {}

tiles[1193] = {collision = COLLISION.CUBE}
tiles[1120] = {collision = COLLISION.CUBE}
tiles[1121] = {collision = COLLISION.CUBE}
tiles[1194] = {collision = COLLISION.CUBE}

tiles[1338] = {collision = {
         0,  0,
        16,  8,
        16, 16,
         0, 16
    }
}

tiles[1339] = {collision = {
         0,  8,
        16, 16,
         0, 16
    }
}

tiles[1340] = {collision = {
         0,  0,
        16, 16,
         0, 16,
    }
}

local props = {
    tileSize = 16,
    tileMap = "tiles.png",
    tiles = tiles
}

return props
