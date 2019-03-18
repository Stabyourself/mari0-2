return {
    width = 12,
    height = 32,

    img = "img/actors/fire_piranha.png",
    quadWidth = 16,
    quadHeight = 32,
    centerX = 8,
    centerY = 16,

    components = {
        ["misc.palettable"] = {
            ["imgPalette"] = {
                {181,  49,  32},
                { 92, 228,  48},
                {255, 255, 255},
                {  0,   0,   0}
            }
        },

        ["animation.frames"] = {
            frames = {1, 2}
        },
        ["movement.truffleShuffle"] = {
            dontTurnAnimation = true,
            maxSpeed = 32,
        },
    }
}