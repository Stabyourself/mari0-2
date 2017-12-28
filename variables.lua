PMETERTICKS = 10


return {
    scale = 1,
    volume = 1,

    tileSize = 16,
    uiHeight = 38,

    gravity = 1125,
    gravityjumping = 480, --gravity while jumping (Only for mario)
    maxYSpeed = 258.75, --258.75

    enemyBounceHeight = 14,

    blockBounceTime = 0.2,
    blockBounceHeight = 0.4,
    jumpLeeway = 6/16,
    blockHitForce = 2,

    coinAnimationTime = 0.14,

    enemiesSpawnAhead = 0,

    portalSize = 32,
    portalReverseRange = math.pi/4+.001,

    pMeterTicks = 7,
    pMeterBlinkTime = 8/60,
    
    cameraScrollLeftBorder = 115,
    cameraScrollRightBorder = 115,
    cameraScrollUpBorder = 47,
    cameraScrollDownBorder = 75,
    
    cameraScrollRate = 300,

    controls = {
        quit = "escape",
        frameDataDisplay = "f",
        boost = "b",
        
        left = "a",
        right = "d",
        down = "s",
        up = "w",
        jump = "space",
        run = "lshift"
    },

    ffKeys = {
        {
            key = "-",
            val = 0.02
        }
    },

    collision = {
        cube = {
            0,  0,
            16,  0,
            16, 16,
            0, 16,
        }
    },
}