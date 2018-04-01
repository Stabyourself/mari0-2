return {
    vsync = 2,
    scale = 1,
    volume = 1,

    tileSize = 16, -- Not fully implemented because typing tileSize a lot is too much work
    uiHeight = 38, -- Move these to SMB3UI?
    uiLineHeight = 1,

    gravity = 1125,
    gravityJumping = 225, --gravity while jumping (Only for mario)
    maxYSpeed = 10000, --258.75

    rotationSpeed = 14, --only a visual effect

    enemyBounceHeight = 14,

    blockBounceTime = 0.2,
    blockBounceHeight = 0.4,
    blockHitForce = 2,

    enemiesSpawnAhead = 0,

    portalSize = 32,
    portalReverseRange = math.pi/4+.001,

    -- Move to smb3mario?
    pMeterTicks = 7,
    pMeterBlinkTime = 8/60,
    
    -- These are all from the center of the screen and towards the center of the player
    cameraScrollLeftBorder = -85,
    cameraScrollRightBorder = 85,
    cameraScrollUpBorder = -53,
    cameraScrollDownBorder = 25,
    
    cameraScrollRate = 300,

    tileTemplates = {
        cube = {
            0,  0,
            16,  0,
            16, 16,
            0, 16,
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