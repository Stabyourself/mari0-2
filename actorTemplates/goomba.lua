return {
    width = 12,
    height = 12,

    img = "img/actors/goomba.png",
    quadWidth = 16,
    quadHeight = 16,
    centerX = 8,
    centerY = 9,

    components = {
        ["misc.palettable"] = {
            ["imgPalette"] = {
                {252, 188, 176},
                {252, 152,  56},
                {  0,   0,   0}
            }
        },

        ["animation.mirror"] = {},
        ["movement.truffleShuffle"] = {
            dontTurnAnimation = true
        },
        ["misc.unrotate"] = {},
        -- ["misc.stompable"] = {},
    }
}