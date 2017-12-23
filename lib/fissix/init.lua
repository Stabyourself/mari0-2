-- Physics libary thing with pixel collisions - MIT License.

fissix = {}

fissix.TRACER_DOWN_SPACE = 8 -- 16
fissix.TRACER_DOWN_EXTEND = 8
fissix.TRACER_BOTTOM_DIST = 8
fissix.TRACER_TOP_SPACE = 4 -- 4
fissix.TRACER_SIDE_DIST = 1
fissix.TRACER_SIDE_DIST_TOP = 5

fissix.World = require "lib/fissix/World"
fissix.PhysObj = require "lib/fissix/PhysObj"
fissix.Tile = require "lib/fissix/Tile"
fissix.TileMap = require "lib/fissix/TileMap"
fissix.Tracer = require "lib/fissix/Tracer"
