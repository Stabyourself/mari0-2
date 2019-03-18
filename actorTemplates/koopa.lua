return {
    width = 12,
    height = 12,

    img = "img/actors/koopa.png",
    quadWidth = 16,
    quadHeight = 32,
    centerX = 8,
    centerY = 25,

    components = {
        ["misc.palettable"] = {
            imgPalette = {
                {252, 188, 176},
                {252, 152,  56},
                {  0,   0,   0}
            }
        },

        ["animation.frames"] = {
        },

        ["movement.truffleShuffle"] = {},
        ["misc.unrotate"] = {},
        ["misc.stompable"] = {},
        ["misc.transforms"] = {
            on = "getStomped",
            into = "koopa_shell"
        }
    }
}