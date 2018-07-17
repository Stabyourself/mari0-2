return {
    debug = {
        -- Physics stuff
        actorHitBox = false,
        tracerDebug = false,
        standingOn = false,
        physicsAdvanced = false,

        -- Actor stuff
        actorQuad = false,
        actorState = false,
        actorComponents = false,

        -- Portal stuff
        portalVector = false,
        portalStencils = false,

        -- UI stuff
        canvas = false,
        reRenders = false,
        reMouses = false,

        -- Misc stuff
        input = true,
        layers = false,
        jprof = false,
        lovebird = false,
    },

    noEnemies = false,
    musicDisabled = true,
    volume = 1,
    scale = 3,
    vsync = false,
    msaa = 0,

    ffKeys = {
        {
            key="+",
            val=3
        },

        {
            key="-",
            val=0.1
        },

        {
            key=".",
            val=0.1
        }
    }
}