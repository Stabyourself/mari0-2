return {
    debug = {
        -- Physics stuff
        actorHitBox = false, -- shows the location of tracers and the hitbox
        tracerDebug = false, -- shows which tracers were checked in the frame
        standingOn = false, -- shows what object/actor an actor is standing on
        physicsAdvanced = false, -- shows the collision for player 1 for every pixel on screen

        -- Actor stuff
        actorQuad = false, -- shows the bounding box of the quad in use
        actorState = false, -- shows the actorState
        actorComponents = false, -- shows all components an actor has

        -- Portal stuff
        portalVector = false, -- draws arrows after going through a portal with the velocity vectors
        portalStencils = false, -- draws the region that is included/excluded to put actors into portals

        -- UI stuff
        canvas = false, -- shows the mouse regions for UI elements
        reRenders = false, -- prints to console when the UI is re-rendered
        reMouses = false, -- prints to console when the mouse regions are re-calculated
        showFPSInTime = true, -- shows the FPS instead of the level time in the SMB 3 UI

        -- World stuff
        animatedTileCallbacks = false,
        layers = false, -- shows borders for level layers
        reSpriteBatchLayers = false, -- prints to console when a level layer's spritebatch is re-made

        -- Misc stuff
        input = true, -- shows a little input display in the bottom left
        jprof = false, -- logs frame data into a file on quit
        lovebird = false, -- enable lövebird debugging (localhost:8000)
        noEnemies = false, -- disables enemy spawning
        musicDisabled = true, -- disables the music
    },

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
