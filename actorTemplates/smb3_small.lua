return {
    width = 12,
    height = 12,

    img = "characters/smb3_mario/small.png",
    quadWidth = 24,
    quadHeight = 24,
    centerX = 11.5,
    centerY = 14,

    dontAutoQuad = true,

    components = {
        ["misc.palettable"] = {
            imgPalette = {
                {252, 188, 176},
                {216,  40,   0},
                {  0,   0,   0}
            },
        },

        ["smb3.animation"] = {
            frames = {
                {
                    type = "8-dir",
                    plusNoGun = true,
                    x = 1,
                    y = 1,
                    names = {
                        "idle",

                        "run",
                        "run",

                        "skid",

                        "jump",

                        "fall",

                        "swim",
                        "swim",

                        "swimUp",
                        "swimUp",
                        "swimUp",
                    },
                },

                {
                    type = "1-dir",
                    plusNoGun = true,
                    x = 1,
                    y = 10,
                    names = {
                        "sprint",
                        "sprint",

                        "fly",

                        "die",

                        "buttSlide",

                        "spin",
                        "spin",
                        "spin",
                        "spin",


                        "holdIdle",

                        "holdRun",
                        "holdRun",

                        "kick",

                        "climb",
                        "climb",
                    }
                }
            }
        },
        ["smb3.movement"] = {},
        ["smb3.jumping"] = {},
        ["smb3.swimming"] = {},
        ["misc.unrotate"] = {},
        ["misc.crosshair"] = {},
        ["misc.portalGun"] = {},
        ["misc.stomps"] = {},
        ["misc.kicks"] = {},
        ["misc.isHurtByContact"] = {},
        ["misc.collectsCoins"] = {},
        ["misc.bumpsBlocks"] = {},
    }
}