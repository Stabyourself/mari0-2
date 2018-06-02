-- Physics libary thing with pixel collisions. Feel free to use it, MIT License

local Physics3 = {}

Physics3collisionMixin = {
    leftColResolve = function() end,
    rightColResolve = function() end,
    topColResolve = function() end,
    bottomColResolve = function() end,
    hasComponent = function() end
}

Physics3.TRACER_BOTTOM_SPACING = 1--8 -- How far apart the downwards tracers are
Physics3.TRACER_BOTTOM_EXTEND = 0 -- How far down below the hitbox the downtracers go, for smoothly walking down slopes
Physics3.TRACER_BOTTOM_DIST = 8 -- How far away the side tracers are from the bottom
Physics3.TRACER_BOTTOM_SIDE_SPACING = 1 -- How far away the bottom tracers are from the edge

Physics3.TRACER_TOP_SPACING = 5 -- How far away the top tracers are from the edge

Physics3.TRACER_SIDE_TOP_DIST = 4 -- How far away the side tracers are from the top

local current_folder = (...):gsub('%.init$', '')

Physics3.Layer = require(current_folder .. ".Layer")
Physics3.World = require(current_folder .. ".World")
Physics3.PhysObj = require(current_folder .. ".PhysObj")
Physics3.Tile = require(current_folder .. ".Tile")
Physics3.TileMap = require(current_folder .. ".TileMap")
Physics3.Tracer = require(current_folder .. ".Tracer")

return Physics3