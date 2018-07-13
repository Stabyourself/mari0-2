-- Physics libary thing with pixel collisions,
-- modified for Mari0 2 (to the point of having to backport it if I wanna use it somewhere else).
-- Feel free to use it, MIT License

local Physics3 = {}

Physics3collisionMixin = {
    leftColResolve = function() end,
    rightColResolve = function() end,
    topColResolve = function() end,
    bottomColResolve = function() end,
    hasComponent = function() end
}

Physics3.TRACER_BOTTOM_SPACING = 2--8 -- How far apart the downwards tracers are
Physics3.TRACER_BOTTOM_EXTEND = 8 -- How far down below the hitbox the downtracers go, for smoothly walking down slopes
Physics3.TRACER_BOTTOM_DIST = 6 -- How far away the side tracers are from the bottom
Physics3.TRACER_BOTTOM_SIDE_SPACING = 1 -- How far away the bottom tracers are from the edge

Physics3.TRACER_TOP_SPACING = 5 -- How far away the top tracers are from the edge

Physics3.TRACER_SIDE_TOP_DIST = 4 -- How far away the side tracers are from the top

local current_folder = (...):gsub('%.init$', '')

Physics3.Layer = require(current_folder .. ".Layer")
Physics3.World = require(current_folder .. ".World")
Physics3.PhysObj = require(current_folder .. ".PhysObj")
Physics3.Tile = require(current_folder .. ".Tile")
Physics3.Cell = require(current_folder .. ".Cell")
Physics3.TileMap = require(current_folder .. ".TileMap")
Physics3.Tracer = require(current_folder .. ".Tracer")

-- Portal
Physics3.Portal = require(current_folder .. ".portal.Portal")
Physics3.PortalParticle = require(current_folder .. ".portal.PortalParticle")
Physics3.PortalThing = require(current_folder .. ".portal.PortalThing")

return Physics3