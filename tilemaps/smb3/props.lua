local tiles = {}

tiles[1119] = VAR("tileTemplates").cube
tiles[1120] = VAR("tileTemplates").cube
tiles[1121] = VAR("tileTemplates").cube

tiles[1192] = VAR("tileTemplates").cube
tiles[1193] = VAR("tileTemplates").cube
tiles[1194] = VAR("tileTemplates").cube

tiles[1337] = {
    collision = {
        0 ,0,
        8, 8,
        16, 0,
        16, 16,
        0, 16,
    }
}

tiles[1265] = {
    angle = -math.pi/8,
    collision = {
        0,  16,
        16,  8,
        16, 16,
    }
}

tiles[1266] = {
    angle = -math.pi/8,
    collision = {
         0,  8,
        16,  0,
        16, 16,
         0, 16,
    }
}

tiles[1267] = {
    angle = -math.pi/4,
    collision = {
         0, 16,
        16,  0,
        16, 16,
    }
}


tiles[1338] = {
    angle = math.pi/8,
    collision = {
         0,  0,
        16,  8,
        16, 16,
         0, 16,
    }
}

tiles[1339] = {
    angle = math.pi/8,
    collision = {
         0,  8,
        16, 16,
         0, 16,
    }
}

tiles[1340] = {
    angle = math.pi/4,
    collision = {
         0,  0,
        16, 16,
         0, 16,
    }
}

tiles[1535] = {
    angle = 0,
    collision = {
         0,  0,
        16,  0,
        16, 16,
    }
}

tiles[1534] = {
    angle = 0,
    collision = {
         0,  0,
        16, 0,
         0, 16,
    }
}


local props = {
    tileSize = 16,
    tileMap = "tiles.png",
    tiles = tiles
}

return props
