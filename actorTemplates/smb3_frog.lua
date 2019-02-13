return {
    width = 12,
    height = 24,

    img = "characters/smb3_mario/frog.png",
    quadWidth = 40,
    quadHeight = 40,
    centerX = 23,
    centerY = 24,

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
                        "run",
                        "run",

                        "skid",

                        "jump",

                        "fall",

                        "duck",

                        "swim",
                        "swim",
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
                        "sprint",
                        "sprint",

                        "fly",

                        "die",

                        "buttSlide",

                        "spin",
                        "spin",
                        "spin",
                        "spin",

                        "spinAir",
                        "spinAir",
                        "spinAir",
                        "spinAir",

                        "holdIdle",

                        "holdRun",
                        "holdRun",
                        "holdRun",
                        "holdRun",

                        "kick",

                        "climb",
                        "climb",

                        "somerSault",
                        "somerSault",
                        "somerSault",
                        "somerSault",
                        "somerSault",
                        "somerSault",
                        "somerSault",
                        "somerSault",

                        "shoot",
                        "shoot",
                        "shoot",

                        "shootAir",
                        "shootAir",
                        "shootAir",
                    }
                }
            }
        },
        ["smb3.movement"] = {},
        ["smb3.jumping"] = {},
        ["smb3.swimming"] = {},
        ["smb3.ducking"] = {},
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