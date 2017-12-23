SCALE = 1
VOLUME = 1

TILESIZE = 16

SCREENWIDTH = 400
SCREENHEIGHT = 240

WIDTH = SCREENWIDTH/TILESIZE
HEIGHT = SCREENHEIGHT/TILESIZE

GRAVITY = 1125
GRAVITYJUMPING = 480 --gravity while jumping (Only for mario)
MAXYSPEED = 2000 --258.75

ENEMYBOUNCEHEIGHT = 14

SCROLLRATE = 80
SUPERSCROLLRATE = 640

SCROLLINGSTART = WIDTH-13 --when the scrolling begins to set in
SCROLLINGCOMPLETE = WIDTH-10 --when the scrolling will be as fast as mario can run
SCROLLINGLEFTSTART = 6 --See above, but for scrolling left
SCROLLINGLEFTCOMPLETE = 4

OBJOFFSCREENDRAW = 0.5 -- to compensate for graphics being wider than the PhysObj

BLOCKBOUNCETIME = 0.2
BLOCKBOUNCEHEIGHT = 0.4

JUMPLEEWAY = 6/16
BLOCKHITFORCE = 2

COINANIMATIONTIME = 0.14

ENEMIESPSAWNAHEAD = 0

CONTROLS = {
    quit = "escape",
    frameDataDisplay = "f",
    
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