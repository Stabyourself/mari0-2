local serialize = require "lib.serialize"
local Cell = require((...):gsub('%.World$', '') .. ".Cell")
local Tile = require((...):gsub('%.World$', '') .. ".Tile")
local TileMap = require((...):gsub('%.World$', '') .. ".TileMap")
local Portal = require((...):gsub('%.World$', '') .. ".portal.Portal")
local World = class("Physics3.World")

local fakeTileInstance = Tile:new()
local fakeCellInstance = Cell:new(nil, nil, nil, fakeTileInstance)

function World:initialize()
    self.tileSize = 16 --lol hardcode

    self.layers = {}

	self.objects = {}
    self.portals = {}
    self.portalVectorDebugs = {}
end

function World:update(dt)
    prof.push("TileMaps")
    for _, tileMap in pairs(self.tileMaps) do
        tileMap:update(dt)
    end
    prof.pop()

    prof.push("Layers")
    for _, layer in pairs(self.layers) do
        layer:update(dt)
    end
    prof.pop()

    prof.push("Portals")
    updateGroup(self.portals, dt)
    prof.pop()

    prof.push("Objects")
    for _, obj in ipairs(self.objects) do
        obj:preMovement()
    end

    for _, obj in ipairs(self.objects) do
        prof.push("Think")
		obj:update(dt)
        prof.pop()

        obj.prevX = obj.x
        obj.prevY = obj.y

        -- Add half of gravity
        obj.speed[2] = obj.speed[2] + (obj.gravity or VAR("gravity")) * dt * 0.5
        obj.speed[2] = math.min((obj.maxSpeedY or VAR("maxYSpeed")), obj.speed[2]) -- Cap speed[2]

        local oldX, oldY = obj.x, obj.y

        obj.frameMovementX = obj.speed[1] * dt
        obj.frameMovementY = obj.speed[2] * dt

        obj.x = obj.x + obj.frameMovementX
        obj.y = obj.y + obj.frameMovementY

		-- Add other half of gravity
        obj.speed[2] = obj.speed[2] + (obj.gravity or VAR("gravity")) * dt * 0.5
        obj.speed[2] = math.min((obj.maxSpeedY or VAR("maxYSpeed")), obj.speed[2]) -- Cap speed[2]

        self:checkPortaling(obj, oldX, oldY)

        local oldX, oldY = obj.x, obj.y

        prof.push("Collisions")
        obj:resolveCollisions()
        prof.pop()

        self:checkPortaling(obj, oldX, oldY)
    end

    for _, obj in ipairs(self.objects) do
        obj:postMovement()
    end
    prof.pop()
end

function World:checkPortaling(obj, oldX, oldY)
    for _, p in ipairs(self.portals) do
        if p.open then
            local iX, iY = linesIntersect(oldX+obj.width/2, oldY+obj.height/2, obj.x+obj.width/2, obj.y+obj.height/2, p.x1, p.y1, p.x2, p.y2)

            if iX and sideOfLine(obj.x+obj.width/2, obj.y+obj.height/2, p.x1, p.y1, p.x2, p.y2) < 0 then -- don't portal when getting into portals from behind
                local x, y, velocityX, velocityY = obj.x+obj.width/2, obj.y+obj.height/2, obj.speed[1], obj.speed[2]
                local angle = math.atan2(velocityY, velocityX)
                local speed = math.sqrt(velocityX^2+velocityY^2)

                local outX, outY, outAngle, angleDiff, reversed = self:doPortal(p, x, y, angle)

                obj.x = outX
                obj.y = outY

                if outAngle < -math.pi*0.25 and outAngle > -math.pi*0.75 then -- todo: questionable way to ensure player makes it out of floorPortals
                    speed = math.max(180, speed)
                end

                obj.speed[1] = math.cos(outAngle)*speed
                obj.speed[2] = math.sin(outAngle)*speed


                obj.angle = normalizeAngle(obj.angle + angleDiff)

                if reversed then
                    obj.animationDirection = -obj.animationDirection
                end

                if VAR("debug").portalVector then
                    self.portalVectorDebugs = {}
                    table.insert(self.portalVectorDebugs, {
                        inX = x,
                        inY = y,
                        inVX = velocityX,
                        inVY = velocityY,

                        outX = obj.x,
                        outY = obj.y,
                        outVX = obj.speed[1],
                        outVY = obj.speed[2],

                        reversed = reversed
                    })
                end

                obj.x = obj.x-obj.width/2
                obj.y = obj.y-obj.height/2

                if obj:checkCollisions() then
                    print("Hey, object " .. tostring(obj) .. " ended up in a wall after portalling. This should be resolved in the future.")
                end

                if obj.portalled then
                    obj:portalled()
                end

                return true
            end
        end
    end

    return false
end

local function emptyStencil() end

local outStencilP
local function outStencil()
    outStencilP.connectsTo:stencilRectangle("out")
end

local inStencilP
local function inStencil()
    inStencilP:stencilRectangle("in")
end

local inPortals = {}

local function drawObject(obj, x, y, r, sx, sy, cx, cy)
    if obj.imgPalette and obj.palette then
        paletteShader.on(obj.imgPalette, obj.palette)
    end

    if obj.quad then
        love.graphics.draw(obj.img, obj.quad, x, y, r, sx, sy, cx, cy)
    else
        love.graphics.draw(obj.img, x, y, r, sx, sy, cx, cy)
    end

    if obj.imgPalette and obj.palette then
        paletteShader.off()
    end
end

function World:draw()
    prof.push("World")
    prof.push("Layers")
    -- Layers
    for i = #self.layers, 1, -1 do -- draw layers in reverse order (1 on top)
        self.layers[i]:draw()
    end

    if VAR("debug").layers then
        for i = #self.layers, 1, -1 do
            self.layers[i]:debugDraw()
        end
    end

    prof.pop()

    prof.push("Portals Back")
    -- Portals (background)
    for _, portal in ipairs(self.portals) do
        portal:draw("background")
    end
    prof.pop()

    prof.push("Behind objects")
    if self.drawBehindObjects then
        self:drawBehindObjects()
    end
    prof.pop()

    prof.push("Objects")
    -- Objects
    love.graphics.setColor(1, 1, 1)

    for _, obj in ipairs(self.objects) do
        local x, y = obj.x+obj.width/2, obj.y+obj.height/2

        local quadX = obj.x+obj.width/2-obj.centerX
        local quadY = obj.y+obj.height/2-obj.centerY
        local quadWidth = obj.quadWidth
        local quadHeight = obj.quadHeight

        if obj.animationDirection == -1 then
            quadX = quadX + obj.centerX*2-obj.quadWidth
        end

        love.graphics.stencil(emptyStencil, "replace")

        -- Portal duplication
        iClearTable(inPortals)

        for _, p in ipairs(self.portals) do
            if p.open then
                if  rectangleOnLine(quadX, quadY, quadWidth, quadHeight, p.x1, p.y1, p.x2, p.y2) and objectWithinPortalRange(p, x, y) then
                    table.insert(inPortals, p)
                end
            end
        end

        for _, p in ipairs(inPortals) do
            local angle = math.atan2(obj.speed[2], obj.speed[1])
            local cX, cY, cAngle, angleDiff, reversed = self:doPortal(p, obj.x+obj.width/2, obj.y+obj.height/2, obj.angle)

            local xScale = 1
            if reversed then
                xScale = -1
            end

            outStencilP = p
            love.graphics.stencil(outStencil, "replace")
            love.graphics.setStencilTest("greater", 0)

            if VAR("debug").portalStencils then
                love.graphics.setColor(0, 1, 0)
                love.graphics.draw(debugCandyImg, debugCandyQuad, self.camera:worldCoords(0, 0))
                love.graphics.setColor(1, 1, 1)
            end

            local a = angleDiff

            if reversed then
                a = a - (obj.angle or 0)
            else
                a = a + (obj.angle or 0)
            end

            drawObject(obj, cX, cY, a, (obj.animationDirection or 1)*xScale, 1, obj.centerX, obj.centerY)

            love.graphics.setStencilTest()

            if VAR("debug").portalStencils then
                love.graphics.rectangle("fill", cX-.5, cY-.5, 1, 1)
            end
        end

        -- Actual position
        love.graphics.stencil(emptyStencil, "replace", 0, false)
        for _, p in ipairs(inPortals) do
            inStencilP = p
            love.graphics.stencil(inStencil, "replace", 1, true)
        end

        if VAR("debug").portalStencils then
            love.graphics.setStencilTest("greater", 0)
            love.graphics.setColor(1, 0, 0)
            love.graphics.draw(debugCandyImg, debugCandyQuad, self.camera:worldCoords(0, 0))
            love.graphics.setColor(1, 1, 1)
        end

        love.graphics.setStencilTest("equal", 0)

        drawObject(obj, x, y, obj.angle or 0, obj.animationDirection or 1, 1, obj.centerX, obj.centerY)

        love.graphics.setStencilTest()

        if VAR("debug").actorQuad then
            love.graphics.rectangle("line", quadX-.5, quadY-.5, quadWidth+1, quadHeight+1)
        end

        obj:draw()
	end
    prof.pop()

    prof.push("Portals Front")
    -- Portals (Foreground)
    for _, portal in ipairs(self.portals) do
        portal:draw("foreground")
    end
    prof.pop()

    -- Debug
    prof.push("Debug")
    if VAR("debug").physicsAdvanced then
        love.graphics.setColor(1, 1, 1)
		self:advancedPhysicsDebug()
    end

    if VAR("debug").portalVector then
        self:portalVectorDebug()
    end

    if VAR("debug").standingOn then
        for _, obj in ipairs(self.objects) do
            obj:standingOnDebugDraw()
        end
    end
    prof.pop("Debug")
    prof.pop("World")
end

function World:addObject(PhysObj)
	table.insert(self.objects, PhysObj)
	PhysObj.World = self
end

function World:loadLevel(data)
    self.layers = {}
    self.tileMaps = {}
    self.tileLookups = {}

    -- Load used tileMaps
    for _, tileMap in ipairs(data.tileMaps) do
        table.insert(self.tileMaps, TileMap:new("tilemaps/" .. tileMap, tileMap))
    end

    -- Load lookup
    for _, lookup in ipairs(data.lookups) do
        local tileMap = lookup[1]
        local tileNo = lookup[2]

        table.insert(self.tileLookups, self.tileMaps[tileMap].tiles[tileNo])
    end

    for i, dataLayer in ipairs(data.layers) do
        local layerX = dataLayer.x or 0
        local layerY = dataLayer.y or 0

        local width = #dataLayer.map
        local height = 0

        local map = {}

        for x = 1, #dataLayer.map do
            map[x] = {}

            height = math.max(height, #dataLayer.map[x])

            for y = 1, #dataLayer.map[1] do
                local unresolvedTile = dataLayer.map[x][y]

                if unresolvedTile ~= 0 then -- 0 means no tile
                    local tile = self.tileLookups[unresolvedTile] -- convert from the saved file's specific tile lookup to the actual tileMap's number

                    assert(tile, string.format("Couldn't load real tile at x=%s, y=%s for requested lookup \"%s\". This may mean that the map is corrupted.", x, y, unresolvedTile))

                    map[x][y] = Cell:new(x, y, dataLayer, tile)
                else
                    map[x][y] = Cell:new(x, y, dataLayer, nil)
                end
            end
        end

        self.layers[i] = Layer:new(self, layerX, layerY, width, height, map)

        for x = 1, #dataLayer.map do
            for y = 1, #dataLayer.map[1] do
                self.layers[i].map[x][y].layer = self.layers[i]
            end
        end
    end
end

function World:saveLevel(outPath)
    local out = {}

    -- build the lookup table
    local lookups = {}

    for _, layer in ipairs(self.layers) do
        for y = 1, layer.height do
            for x = 1, layer.width do
                local tile = layer.map[x][y].tile

                if tile then
                    -- See if the tile is already in the table
                    local found = false

                    for i, lookupTile in ipairs(lookups) do
                        if lookupTile.tileNum == tile.num and lookupTile.tileMap == tile.tileMap then
                            found = i
                            break
                        end
                    end

                    if found then
                        lookups[found].count = lookups[found].count + 1
                    else
                        table.insert(lookups, {tileMap = tile.tileMap, tileNum = tile.num, count = 1})
                    end
                end
            end
        end
    end

    table.sort(lookups, function(a, b) return a.count > b.count end)

    -- build tileMap order
    local tileMaps = {}
    for _, lookup in ipairs(lookups) do
        local tileMapName = lookup.tileMap.name

        local tileMapI = false

        for i, tileMap in ipairs(tileMaps) do
            if tileMap.name == tileMapName then
                tileMapI = i
                break
            end
        end

        if not tileMapI then
            table.insert(tileMaps, {name = tileMapName, count = 0})
            tileMapI = #tileMaps
        end

        tileMaps[tileMapI].count = tileMaps[tileMapI].count + 1
    end

    table.sort(tileMaps, function(a, b) return a.count > b.count end)

    out.tileMaps = {}

    local tileMapLookup = {}
    for i, tileMap in ipairs(tileMaps) do
        tileMapLookup[tileMap.name] = i

        table.insert(out.tileMaps, tileMap.name)
    end

    -- build lookups
    out.lookups = {}

    for _, lookup in ipairs(lookups) do
        -- find the proper tileMap index for this
        local tileMapI = false

        for i, tileMap in ipairs(tileMaps) do
            if tileMap.name == lookup.tileMap.name then
                tileMapI = i
                break
            end
        end

        table.insert(out.lookups, {tileMapI, lookup.tileNum})
    end

    -- build map based on lookups
    out.layers = {}

    for i, layer in ipairs(self.layers) do
        out.layers[i] = {}
        out.layers[i].map = {}
        out.layers[i].x = layer.x
        out.layers[i].y = layer.y

        for x = 1, layer.width do
            out.layers[i].map[x] = {}

            for y = 1, layer.height do
                local tile = layer.map[x][y].tile

                if tile then
                    --find the lookup
                    local tileMapI = tileMapLookup[tile.tileMap.name]
                    local tileI = tile.num

                    local lookupI = false

                    for i, lookup in ipairs(out.lookups) do
                        if lookup[1] == tileMapI and lookup[2] == tileI then
                            lookupI = i
                            break
                        end
                    end

                    out.layers[i].map[x][y] = lookupI
                else
                    out.layers[i].map[x][y] = 0
                end
            end
        end
    end

    -- Entities
    out.entities = {}

    table.insert(out.entities, {type="spawn", x=self.spawnX, y=self.spawnY})

    love.filesystem.write(outPath, serialize.tstr(out))
end

function World:advancedPhysicsDebug()
    if not self.advancedPhysicsDebugImg or true then
        if not self.advancedPhysicsDebugImgData then
            self.advancedPhysicsDebugImgData = love.image.newImageData(self.camera.w, self.camera.h)
        end

        self.advancedPhysicsDebugImgData:mapPixel(function (x, y)
            local worldX = math.round(self.camera.x-self.camera.w/2+x)
            local worldY = math.round(self.camera.y-self.camera.h/2+y)
            if self:checkCollision(worldX, worldY, game.players[1].actor) then
                return 1, 1, 1, 1
            else
                return 1, 1, 1, 0
            end
        end)

        self.advancedPhysicsDebugImg = love.graphics.newImage(self.advancedPhysicsDebugImgData)
    end

    love.graphics.draw(self.advancedPhysicsDebugImg, math.round(self.camera.x-self.camera.w/2), math.round(self.camera.y-self.camera.h/2))
end

function World:portalVectorDebug()
    for _, portalVectorDebug in ipairs(self.portalVectorDebugs) do
        if not portalVectorDebug.reversed then
            love.graphics.setColor(1, 1, 0)
        else
            love.graphics.setColor(1, 0, 0)
        end

        worldArrow(portalVectorDebug.inX, portalVectorDebug.inY, portalVectorDebug.inVX, portalVectorDebug.inVY)
        worldArrow(portalVectorDebug.outX, portalVectorDebug.outY, portalVectorDebug.outVX, portalVectorDebug.outVY)
    end
end

function World:checkCollision(x, y, obj, vector, portalled)
    if obj and not portalled then -- don't re-portal points because that's still
        -- Portal hijacking
        for _, portal in ipairs(self.portals) do
            if portal.open and obj.inPortals[portal] then -- only if the player is "in front" of the portal
                -- check if pixel is inside portal wallspace
                -- rotate x, y around portal origin
                local nx, ny = pointAroundPoint(x, y, portal.x1, portal.y1, -portal.angle)

                -- comments use an up-pointing portal as example
                if nx > portal.x1 and nx < portal.x1+portal.size then -- point is horizontally within the portal
                    if ny > portal.y1 then
                        if ny < portal.y1 + 1 then -- first pixel's free, because bumpy conversion from vector positions to pixel collision can create some bad effects
                            return false
                        else -- point is inside portal
                            local newX, newY = self:portalPoint(x, y, portal, portal.connectsTo) -- warp point or something

                            return self:checkCollision(newX, newY, obj, vector, true)
                        end

                    elseif ny > portal.y1 - 0.00000001 then -- stops a thin line covering 45° portals
                        return false
                    end
                else
                    if ny > portal.y1 then

                        if ny < portal.y1 + 2 then -- add a thin line of collision to the portal's edges
                            return fakeCellInstance
                        else
                            local newX, newY = self:portalPoint(x, y, portal, portal.connectsTo) -- warp point or something

                            return self:checkCollision(newX, newY, obj, vector, true)
                        end
                    end
                end
            end
        end
    end

    -- level boundaries
    if x < 0 or x >= self:getXEnd()*16 then -- todo: bad for performance due to recalculation of XEnd!
        return fakeCellInstance
    end

    -- World
    for _, layer in ipairs(self.layers) do
        local cell = layer:checkCollision(math.round(x), math.round(y), obj, vector)

        if cell then
            return cell
        end
    end

    -- Actors
    -- todo: quad tree magic

    for _, obj2 in ipairs(self.objects) do
        if obj ~= obj2 then
            if obj2:checkCollision(math.round(x), math.round(y)) then
                return obj2
            end
        end
    end

    return false
end

function World:getXStart()
    local x = math.huge

    for _, layer in ipairs(self.layers) do
        x = math.min(x, layer:getXStart())
    end

    return x
end

function World:getYStart()
    local y = math.huge

    for _, layer in ipairs(self.layers) do
        y = math.min(y, layer:getYStart())
    end

    return y
end

function World:getXEnd()
    local x = -math.huge

    for _, layer in ipairs(self.layers) do
        x = math.max(layer:getXEnd(), x)
    end

    return x
end

function World:getYEnd()
    local y = -math.huge

    for _, layer in ipairs(self.layers) do
        y = math.max(layer:getYEnd(), y)
    end

    return y
end

function World:getWidth()
    return self:getXEnd() - self:getXStart() + 1
end

function World:getHeight()
    return self:getYEnd() - self:getYStart() + 1
end

local function rayCastGetColSide(side, stepX, stepY)
    if side == "ver" then
        if stepX > 0 then
            return 4
        else
            return 2
        end
    else
        if stepY > 0 then
            return 1
        else
            return 3
        end
    end
end

function World:rayCast(x, y, dir) -- Uses code from http://lodev.org/cgtutor/raycasting.html - thanks!
    local rayPosX = x+1
    local rayPosY = y+1
    local rayDirX = math.cos(dir)
    local rayDirY = math.sin(dir)

    local mapX = math.floor(rayPosX)
    local mapY = math.floor(rayPosY)

    -- Check if the start position is outside the map
    local startedOutOfMap = false
    local wasInMap = false

    if not self:inMap(mapX, mapY) then
        -- Check if the ray will return inMap
        local xStart = self:getXStart()
        local yStart = self:getYStart()
        local xEnd = self:getXEnd()
        local yEnd = self:getYEnd()

        local rayPos2X = rayPosX + rayDirX*100000
        local rayPos2Y = rayPosY + rayDirY*100000 -- GOOD CODE (todo? may be fine)

        if not rectangleOnLine(xStart, yStart, xEnd-xStart+1, yEnd-yStart+1, rayPosX, rayPosY, rayPos2X, rayPos2Y) then
            return false
        end

        startedOutOfMap = true
    end

    -- length of ray from one x or y-side to next x or y-side
    local deltaDistX = math.sqrt(1 + (rayDirY * rayDirY) / (rayDirX * rayDirX))
    local deltaDistY = math.sqrt(1 + (rayDirX * rayDirX) / (rayDirY * rayDirY))

    -- what direction to step in x or y-direction (either +1 or -1)
    local stepX, stepY

    local hit = false -- was there a wall hit?
    local side -- was a NS or a EW wall hit?
    local sideDistX, sideDistY
    -- calculate step and initial sideDist
    if rayDirX < 0 then
        stepX = -1
        sideDistX = (rayPosX - mapX) * deltaDistX
    else
        stepX = 1
        sideDistX = (mapX + 1.0 - rayPosX) * deltaDistX
    end

    if rayDirY < 0 then
        stepY = -1
        sideDistY = (rayPosY - mapY) * deltaDistY
    else
        stepY = 1
        sideDistY = (mapY + 1.0 - rayPosY) * deltaDistY
    end

    local firstCheck = true

    -- perform DDA
    while not hit do
        -- Check if ray has hit something (or went outside the map)
        for i, layer in ipairs(self.layers) do
            if not layer.movement then
                local cubeCol = false

                if not self:inMap(mapX, mapY) then
                    if not startedOutOfMap or wasInMap then
                        cubeCol = true
                    end
                else
                    wasInMap = true

                    if layer:inMap(mapX, mapY) then
                        local tile = layer:getTile(mapX, mapY)

                        if tile and tile.collision then
                            if  tile.props.exclusiveCollision and
                                (tile.props.exclusiveCollision ~= rayCastGetColSide(side, stepX, stepY) or
                                firstCheck) then
                                -- don't collide when coming from the wrong side in exclusiveCollision
                                -- also don't collide if we are inside an exclusiveCollision

                            elseif tile.collision == VAR("tileTemplates").cube then
                                cubeCol = true

                            else

                                -- complicated polygon stuff
                                local col

                                -- Trace line
                                local t1x, t1y = x, y
                                local t2x, t2y = x+math.cos(dir)*100000, y+math.sin(dir)*100000 --todo find a better way for this

                                for i = 1, #tile.collision, 2 do
                                    local nextI = i + 2

                                    if nextI > #tile.collision then
                                        nextI = 1
                                    end

                                    -- Polygon edge line
                                    local p1x, p1y = tile.collision[i]/self.tileSize+mapX-1, tile.collision[i+1]/self.tileSize+mapY-1
                                    local p2x, p2y = tile.collision[nextI]/self.tileSize+mapX-1, tile.collision[nextI+1]/self.tileSize+mapY-1

                                    local interX, interY = linesIntersect(p1x, p1y, p2x, p2y, t1x, t1y, t2x, t2y)
                                    if interX then
                                        local dist = math.sqrt((t1x-interX)^2 + (t1y-interY)^2)

                                        if not col or dist < col.dist then
                                            col = {
                                                dist = dist,
                                                x = interX,
                                                y = interY,
                                                side = (i+1)/2
                                            }
                                        end
                                    end
                                end

                                if col then
                                    return layer, mapX, mapY, col.x, col.y, col.side
                                end
                            end
                        end
                    end
                end

                if firstCheck then
                    if cubeCol then
                        return false
                    end
                end

                if cubeCol then
                    local absX = mapX-1
                    local absY = mapY-1

                    if side == "ver" then
                        local dist = (mapX - rayPosX + (1 - stepX) / 2) / rayDirX
                        local hitDist = rayPosY + dist * rayDirY - math.floor(mapY)

                        absY = absY + hitDist
                    else
                        local dist = (mapY - rayPosY + (1 - stepY) / 2) / rayDirY
                        local hitDist = rayPosX + dist * rayDirX - math.floor(mapX)

                        absX = absX + hitDist
                    end

                    local colSide = rayCastGetColSide(side, stepX, stepY)

                    if colSide == 2 then
                        absX = absX + 1
                    elseif colSide == 3 then
                        absY = absY + 1
                    end

                    return layer, mapX, mapY, absX, absY, colSide
                end
            end
        end

        -- jump to next map square, OR in x-direction, OR in y-direction
        if sideDistX < sideDistY then
            sideDistX = sideDistX + deltaDistX
            mapX = mapX + stepX
            side = "ver"
        else
            sideDistY = sideDistY + deltaDistY
            mapY = mapY + stepY
            side = "hor"
        end

        firstCheck = false
    end
end

function World:inMap(x, y)
    return  x >= self:getXStart() and x <= self:getXEnd() and
            y >= self:getYStart() and y <= self:getYEnd()
end

function World:coordinateToWorld(x, y)
    return x*self.tileSize, y*self.tileSize
end

function World:coordinateToCamera(x, y)
    local x, y = self:coordinateToWorld(x, y)
    return self.camera:cameraCoords(x, y)
end

function World:worldToCoordinate(x, y)
    return math.floor(x/self.tileSize)+1, math.floor(y/self.tileSize)+1
end

function World:cameraToCoordinate(x, y)
    return self:worldToCoordinate(self:cameraToWorld(x, y))
end

function World:cameraToWorld(x, y)
    return self.camera:worldCoords(x, y)
end

function World:mouseToWorld()
    local x, y = self:getMouse()

    return self.camera:worldCoords(x, y)
end

function World:mouseToCoordinate()
    local x, y = self:getMouse()

    return self:cameraToCoordinate(x, y)
end

function World:getMouse()
    local x, y = love.mouse.getPosition()
    return x/VAR("scale"), y/VAR("scale")
end

function World:getTile(x, y)
    for _, layer in ipairs(self.layers) do
        local tile = layer:getTile(x, y)

        if tile then
            return tile
        end
    end
end

function World:getCoordinateRectangle(x, y, w, h, clamp)
    local lx, rx, ty, by

    if w < 0 then
        x = x + w
        w = -w
    end

    if h < 0 then
        y = y + h
        h = -h
    end

    lx, ty = self:worldToCoordinate(x+8, y+8)
    rx, by = self:worldToCoordinate(x+w-8, y+h-8)

    if clamp then
        if lx > self:getXEnd() or rx < 1 or ty > self:getYEnd() or by < 1 then -- selection is completely outside layer
            return 0, -1, 0, -1
        end

        lx = math.max(lx, self:getXStart())
        rx = math.min(rx, self:getXEnd())
        ty = math.max(ty, self:getYStart())
        by = math.min(by, self:getYEnd())
    end

    return lx, rx, ty, by
end

function World:attemptPortal(layer, tileX, tileY, side, x, y, color, ignoreP)
    local x1, y1, x2, y2 = self:checkPortalSurface(layer, tileX, tileY, side, x, y, ignoreP)

    if x1 then
        -- make sure that the surface is big enough to hold a portal
        local length = math.sqrt((x1-x2)^2+(y1-y2)^2)

        if length >= VAR("portalSize") then
            local angle = math.atan2(y2-y1, x2-x1)
            local middleProgress = math.sqrt((x-x1)^2+(y-y1)^2)/length

            local leftSpace = middleProgress*length
            local rightSpace = (1-middleProgress)*length

            if leftSpace < VAR("portalSize")/2 then -- move final portal position to the right
                middleProgress = (VAR("portalSize")/2/length)
            elseif rightSpace < VAR("portalSize")/2 then -- move final portal position to the left
                middleProgress = 1-(VAR("portalSize")/2/length)
            end

            local mX = x1 + (x2-x1)*middleProgress
            local mY = y1 + (y2-y1)*middleProgress

            local p1x = math.cos(angle+math.pi)*VAR("portalSize")/2+mX - .5
            local p1y = math.sin(angle+math.pi)*VAR("portalSize")/2+mY - .5

            local p2x = math.cos(angle)*VAR("portalSize")/2+mX - .5
            local p2y = math.sin(angle)*VAR("portalSize")/2+mY - .5

            local portal = Portal:new(self, p1x, p1y, p2x, p2y, color)
            table.insert(self.portals, portal)

            return portal
        end
    end
end

function World:portalPoint(x, y, inPortal, outPortal, reversed)
    if reversed == nil then
        reversed = inPortal:getReversed(outPortal)
    end

    local newX, newY

    if not reversed then
        -- Rotate around entry portal (+ half a turn)
        newX, newY = pointAroundPoint(x, y, inPortal.x2, inPortal.y2, -inPortal.angle-math.pi)

        -- Translate by portal offset (from opposite sides)
        newX = newX + (outPortal.x1 - inPortal.x2)
        newY = newY + (outPortal.y1 - inPortal.y2)
    else
        -- Rotate around entry portal
	    newX, newY = pointAroundPoint(x, y, inPortal.x1, inPortal.y1, -inPortal.angle)

        -- mirror along entry portal
        newY = newY + (inPortal.y1-newY)*2

        -- Translate by portal offset
        newX = newX + (outPortal.x1 - inPortal.x1)
        newY = newY + (outPortal.y1 - inPortal.y1)
    end

	-- Rotate around exit portal
    return pointAroundPoint(newX, newY, outPortal.x1, outPortal.y1, outPortal.angle)
end

function World:doPortal(portal, x, y, angle)
    -- Check whether to reverse portal direction (when portal face the same way)
    local reversed = portal:getReversed(portal.connectsTo)

	-- Modify speed
    local r
    local rDiff

    if not reversed then
        rDiff = portal.connectsTo.angle - portal.angle - math.pi
        r = rDiff + angle
    else
        rDiff = portal.connectsTo.angle + portal.angle + math.pi
        r = portal.connectsTo.angle + portal.angle - angle
    end

    -- Modify position
    local newX, newY = self:portalPoint(x, y, portal, portal.connectsTo, reversed)

    return newX, newY, r, rDiff, reversed
end

local windMill = {
    -1, -1,
    0, -1,
    1, -1,
    1,  0,
    1,  1,
    0,  1,
    -1,  1,
    -1, 0
}

local function walkSide(self, layer, tile, tileX, tileY, side, dir) -- needs a rewrite.
    local nextX, nextY, angle, nextAngle, nextTileX, nextTileY, nextSide
    local x, y = 0, 0
    local first = true

    local found

    repeat
        found = false

        if dir == "clockwise" then
            x = tile.collision[side*2-1]
            y = tile.collision[side*2]

            nextSide = side + 1

            if nextSide > #tile.collision/2 then
                nextSide = 1
            end
        elseif dir == "anticlockwise" then
            --don't move to nextside on the first, because it's already on it
            if first then
                nextSide = side

                -- Move x and y though because reasons
                local tempSide = side + 1

                if tempSide > #tile.collision/2 then
                    tempSide = 1
                end

                x = tile.collision[tempSide*2-1]
                y = tile.collision[tempSide*2]
            else
                nextSide = side - 1
                if nextSide == 0 then
                    nextSide = #tile.collision/2
                end
            end
        end

        nextX = tile.collision[nextSide*2-1]
        nextY = tile.collision[nextSide*2]

        nextAngle = math.atan2(nextX-x, nextY-y)

        if first then
            angle = nextAngle
        end

        if nextAngle == angle then
            --check which neighbor this line might continue
            if nextX == 0 or nextX == 16 or nextY == 0 or nextY == 16 then
                local moveX = 0
                local moveY = 0

                if nextX == 0 and nextY ~= 0 and nextY ~= 16 then -- LEFT
                    moveX = -1
                elseif nextX == 16 and nextY ~= 0 and nextY ~= 16 then -- RIGHT
                    moveX = 1
                elseif nextY == 0 and nextX ~= 0 and nextX ~= 16 then -- UP
                    moveY = -1
                elseif nextY == 16 and nextX ~= 0 and nextX ~= 16 then -- DOWN
                    moveY = 1

                else
                    if nextX == 0 and nextY == 0 then -- top left, either upleft or up or left
                        if dir == "clockwise" and x == 0 then -- UP
                            moveY = -1
                        elseif dir == "anticlockwise" and y == 0 then -- LEFT
                            moveX = -1
                        else -- upleft
                            moveX = -1
                            moveY = -1
                        end

                    elseif nextX == 16 and nextY == 0 then -- top right, either upright or right or up
                        if dir == "clockwise" and y == 0 then -- RIGHT
                            moveX = 1
                        elseif dir == "anticlockwise" and x == 16 then -- UP
                            moveY = -1
                        else -- UPRIGHT
                            moveX = 1
                            moveY = -1
                        end

                    elseif nextX == 16 and nextY == 16 then -- bottom right, either downright or down or right
                        if dir == "clockwise" and x == 16 then -- DOWN
                            moveY = 1
                        elseif dir == "anticlockwise" and y == 16 then -- RIGHT
                            moveX = 1
                        else -- downright
                            moveX = 1
                            moveY = 1
                        end

                    elseif nextX == 0 and nextY == 16 then -- bottom left, either downleft or left or down
                        if dir == "clockwise" and y == 16 then -- LEFT
                            moveX = -1
                        elseif dir == "anticlockwise" and x == 0 then -- DOWN
                            moveY = 1
                        else -- downleft
                            moveX = -1
                            moveY = 1
                        end
                    end
                end

                -- Check if there's a tile in the way

                -- Dirty check, maybe change
                -- Find where on the "windmill" we are
                local pos
                for i = 1, #windMill, 2 do
                    if windMill[i] == moveX and windMill[i+1] == moveY then
                        pos = (i+1)/2
                    end
                end

                local nextPos

                if dir == "clockwise" then
                    nextPos = pos - 1

                    if nextPos == 0 then
                        nextPos = 8
                    end
                elseif dir == "anticlockwise" then
                    nextPos = pos + 1

                    if nextPos > 8 then
                        nextPos = 1
                    end
                end

                local checkTileX = tileX + windMill[nextPos*2-1]
                local checkTileY = tileY + windMill[nextPos*2]

                local checkTile

                if layer:inMap(checkTileX, checkTileY) then
                    checkTile = layer:getTile(checkTileX, checkTileY)
                end

                nextTileX = tileX + moveX
                nextTileY = tileY + moveY

                x = nextX - moveX*self.tileSize
                y = nextY - moveY*self.tileSize

                tileX = nextTileX
                tileY = nextTileY

                if not checkTile or not checkTile.collision then -- make sure the potential next tile doesn't have a block blocking it
                    --check if next tile has a point on the same spot as nextX/nextY
                    if layer:inMap(tileX, tileY) then
                        local nextTile = layer:getTile(tileX, tileY)
                        if nextTile and nextTile.collision then
                            local points = nextTile.collision

                            for i = 1, #points, 2 do
                                if points[i] == x and points[i+1] == y then
                                    local nextBlockSide = (i+1)/2

                                    if dir == "anticlockwise" then
                                        nextBlockSide = nextBlockSide - 1

                                        if nextBlockSide == 0 then
                                            nextBlockSide = #nextTile.collision/2
                                        end
                                    end

                                    -- check whether it's a platform and a wrong side
                                    if nextTile.props.exclusiveCollision and nextTile.props.exclusiveCollision ~= side then
                                        -- not valid
                                    elseif not nextTile:sidePortalable(nextBlockSide) then
                                        -- not valid either!
                                    else
                                        found = true
                                        side = (i+1)/2
                                        tile = nextTile
                                    end
                                end
                            end
                        end
                    end
                end
            else
                x = nextX
                y = nextY
            end
        end

        first = false
    until not found

    return tileX+x/self.tileSize-1, tileY+y/self.tileSize-1
end

function World:checkPortalSurface(layer, tileX, tileY, side, worldX, worldY, ignoreP)
    if not layer:inMap(tileX, tileY) then
        return false
    end

    local tile = layer:getTile(tileX, tileY)

    if not tile or not tile.collision then -- Not sure if this should ever happen
        return false
    end

    if not tile:sidePortalable(side) then
        return false
    end

    prof.push("walkSide")
    local startX, startY = walkSide(self, layer, tile, tileX, tileY, side, "anticlockwise")
    local endX, endY = walkSide(self, layer, tile, tileX, tileY, side, "clockwise")
    prof.pop()

    startX, startY = self:coordinateToWorld(startX, startY)
    endX, endY = self:coordinateToWorld(endX, endY)

    local angle = tile:getSideAngle(side)

    -- Do some magic to determine whether there's portals blocking off sections of our portal surface
    worldX = worldX - 0.5 -- necessary because portals live on off-pixels
    worldY = worldY - 0.5

    for _, p in ipairs(self.portals) do
        if p ~= ignoreP then
            if math.abs(p.angle - angle) < 0.00001 or p.angle + angle < 0.00001 then -- angle is the same! (also good code on that 0.00001)
                local onLine = pointOnLine(p.x1, p.y1, p.x2, p.y2, worldX, worldY)
                if onLine then -- surface is the same! (or at least on the same line which is good enough)
                    if onLine >= 0 then -- Check on which side of the same surface portal we are
                        if math.abs(startX-.5-worldX) > math.abs(p.x2-worldX) or
                            math.abs(startY-.5-worldY) > math.abs(p.y2-worldY) then -- finally check that we are not accidentally lengthening the portal surface
                            startX = p.x2+.5
                            startY = p.y2+.5
                        end

                    else
                        if math.abs(endX-.5-worldX) > math.abs(p.x1-worldX) or
                            math.abs(endY-.5-worldY) > math.abs(p.y1-worldY) then
                            endX = p.x1+.5
                            endY = p.y1+.5
                        end
                    end
                end
            end
        end
    end

    return startX, startY, endX, endY, angle
end

return World