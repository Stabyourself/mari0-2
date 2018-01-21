PMETERTICKS = 10


return {
    vsync = 2,
    scale = 1,
    volume = 1,

    tileSize = 16,
    uiHeight = 38,
    uiLineHeight = 1,

    gravity = 1125,
    gravityjumping = 480, --gravity while jumping (Only for mario)
    maxYSpeed = 10000, --258.75

    rotationSpeed = 14, --only a visual effect

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
    
    cameraScrollLeftBorder = -85,
    cameraScrollRightBorder = 85,
    cameraScrollUpBorder = -53,
    cameraScrollDownBorder = 25,
    
    cameraScrollRate = 300,

    tileTemplates = {
        cube = {
            angle = 0,
            collision = {
                0,  0,
                16,  0,
                16, 16,
                0, 16,
            }
        },

        smallSlopeRight1 = {
            angle = -math.pi/8,
            collision = {
                0,  16,
                16,  8,
                16, 16,
            }
        },

        smallSlopeRight2 = {
            angle = -math.pi/8,
            collision = {
                 0,  8,
                16,  0,
                16, 16,
                 0, 16,
            }
        },

        bigSlopeRight = {
            angle = -math.pi/4,
            collision = {
                 0, 16,
                16,  0,
                16, 16,
            }
        },

        smallSlopeLeft1 = {
            angle = math.pi/8,
            collision = {
                 0,  0,
                16,  8,
                16, 16,
                 0, 16,
            }
        },

        smallSlopeLeft2 = {
            angle = math.pi/8,
            collision = {
                 0,  8,
                16, 16,
                 0, 16,
            }
        },

        bigSlopeLeft = {
            angle = math.pi/4,
            collision = {
                 0,  0,
                16, 16,
                 0, 16,
            }
        },
        
        bigSlopeLeftUpsideDown = {
            angle = 0,
            collision = {
                 0,  0,
                16, 0,
                 0, 16,
            }
        },

        bigSlopeRightUpsideDown = {
            angle = 0,
            collision = {
                 0,  0,
                16,  0,
                16, 16,
            }
        }
    },
    
    editor = {
        cameraSpeed = 300
    }
}