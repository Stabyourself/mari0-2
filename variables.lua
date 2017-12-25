SCALE = 1
VOLUME = 1

TILESIZE = 16
UIHEIGHT = 38

GRAVITY = 1125
GRAVITYJUMPING = 480 --gravity while jumping (Only for mario)
MAXYSPEED = 100000000--258.75 --258.75

ENEMYBOUNCEHEIGHT = 14

SCROLLRATE = 80
SUPERSCROLLRATE = 640

OBJOFFSCREENDRAW = 0.5 -- to compensate for graphics being wider than the PhysObj

BLOCKBOUNCETIME = 0.2
BLOCKBOUNCEHEIGHT = 0.4

JUMPLEEWAY = 6/16
BLOCKHITFORCE = 2

COINANIMATIONTIME = 0.14

ENEMIESPSAWNAHEAD = 0

PORTALSIZE = 32

PMETERTICKS = 7

CONTROLS = {
    quit = "escape",
    frameDataDisplay = "f",
    boost = "b",
    
    left = "a",
    right = "d",
    jump = "space",
    run = "lshift"
}

FFKEYS = {
    {
        key = "-",
        val = 0.02
    }
}

COLLISION = {}
COLLISION.CUBE = {
     0,  0,
    16,  0,
    16, 16,
     0, 16,
}