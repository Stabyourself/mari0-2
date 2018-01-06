-- Physics libary thing with pixel collisions - MIT License.

fissix = {}

fissix.TRACER_BOTTOM_SPACING = 1--8 -- How far apart the downwards tracers are
fissix.TRACER_BOTTOM_EXTEND = 8 -- How far down below the hitbox the downtracers go, for smoothly walking down slopes
fissix.TRACER_BOTTOM_DIST = 8 -- How far away the side tracers are from the bottom
fissix.TRACER_BOTTOM_SIDE_SPACING = 1 -- How far away the bottom tracers are from the edge

fissix.TRACER_TOP_SPACING = 5 -- How far away the top tracers are from the edge

fissix.TRACER_SIDE_TOP_DIST = 4 -- How far away the side tracers are from the top

local current_folder = (...):gsub('%.init$', '')

fissix.World = require(current_folder .. "/World")
fissix.PhysObj = require(current_folder .. "/PhysObj")
fissix.Tile = require(current_folder .. "/Tile")
fissix.TileMap = require(current_folder .. "/TileMap")
fissix.Tracer = require(current_folder .. "/Tracer")
