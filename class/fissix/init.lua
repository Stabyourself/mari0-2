-- Physics libary thing with pixel collisions - MIT License.

fissix = {}

fissix.TRACER_BOTTOM_SPACING = 8 -- How far apart the downwards tracers are
fissix.TRACER_BOTTOM_EXTEND = 8 -- How far down below the hitbox the downtracers go, for smoothly walking down slopes
fissix.TRACER_BOTTOM_DIST = 8 -- How far away the side tracers are from the bottom
fissix.TRACER_BOTTOM_SIDE_SPACING = 1 -- How far away the bottom tracers are from the edge

fissix.TRACER_TOP_SPACING = 5 -- How far away the top tracers are from the edge

fissix.TRACER_SIDE_TOP_DIST = 4 -- How far away the side tracers are from the top

fissix.World = require "class/fissix/World"
fissix.PhysObj = require "class/fissix/PhysObj"
fissix.Tile = require "class/fissix/Tile"
fissix.TileMap = require "class/fissix/TileMap"
fissix.Tracer = require "class/fissix/Tracer"
