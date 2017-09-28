WIDTH = 25
HEIGHT = 15

GRAVITY = 80
GRAVITYJUMPING = 30 --gravity while jumping (Only for mario)
MAXYSPEED = 100

JUMPFORCE = 16--16
JUMPFORCEADD = 1.9 --how much jumpforce is added at top speed (linear from 0 to topspeed)

WALKACCELERATION = 8 --acceleration of walking on ground
RUNACCELERATION = 16 --acceleration of running on ground
WALKACCELERATIONAIR = 8 --acceleration of walking in the air
RUNACCLERATIONAIR = 16 --acceleration of running in the air
MINSPEED = 0.7 --When FRICTION is in effect and speed falls below this, speed is set to 0
MAXWALKSPEED = 6.4 --fastest speedx when walking
MAXRUNSPEED = 9.0 --fastest speedx when running
FRICTION = 14 --amount of speed that is substracted when not pushing buttons, as well as speed added to acceleration when changing directions
SUPERFRICTION = 100 --see above, but when speed is greater than MAXRUNSPEED
FRICTIONAIR = 0 --see above, but in air
AIRSLIDEFACTOR = 0.8 --multiply of acceleration in air when changing direction

TILESIZE = 16
RUNANIMATIONTIME = 0.1

DEPTHMUL = 0.3