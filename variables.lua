SCALE = 1
VOLUME = 1

TILESIZE = 16

SCREENWIDTH = 400
SCREENHEIGHT = 240

WIDTH = SCREENWIDTH/TILESIZE
HEIGHT = SCREENHEIGHT/TILESIZE

GRAVITY = 1280
GRAVITYJUMPING = 480 --gravity while jumping (Only for mario)
MAXYSPEED = 1600

JUMPFORCE = 256
JUMPFORCEADD = 30.4 --how much jumpforce is added at top speed (linear from 0 to topspeed)

WALKACCELERATION = 128 --acceleration of walking on ground
RUNACCELERATION = 256 --acceleration of running on ground
WALKACCELERATIONAIR = 128 --acceleration of walking in the air
RUNACCLERATIONAIR = 256 --acceleration of running in the air
MINSPEED = 11.2 --When FRICTION is in effect and speed falls below this, speed is set to 0
MAXWALKSPEED = 102.4 --fastest speedx when walking
MAXRUNSPEED = 144 --fastest speedx when running
FRICTION = 224 --amount of speed that is substracted when not pushing buttons, as well as speed added to acceleration when changing directions
SUPERFRICTION = 1600 --see above, but when speed is greater than MAXRUNSPEED
FRICTIONAIR = 0 --see above, but in air
AIRSLIDEFACTOR = 0.8 --multiply of acceleration in air when changing direction

ENEMYBOUNCEHEIGHT = 14

SCROLLRATE = 80
SUPERSCROLLRATE = 640

SCROLLINGSTART = WIDTH-13 --when the scrolling begins to set in
SCROLLINGCOMPLETE = WIDTH-10 --when the scrolling will be as fast as mario can run
SCROLLINGLEFTSTART = 6 --See above, but for scrolling left
SCROLLINGLEFTCOMPLETE = 4

RUNANIMATIONTIME = 1.6

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