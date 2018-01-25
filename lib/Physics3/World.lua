local World = class("Physics3.World")

function World:initialize()
    self.tileSize = 16 --lol hardcode
    
    self.map = {}
	
	self.objects = {}
    self.portals = {}
    self.portalVectorDebugs = {}
end

function World:update(dt)
    prof.push("Tiles")
    for _, v in pairs(self.tileMaps) do
        v:update(dt)
    end
    prof.pop()

    prof.push("Portals")
    updateGroup(self.portals, dt)
    prof.pop()
    
    prof.push("Objects")
    for i, obj in ipairs(self.objects) do
        prof.push("Think")
		obj:update(dt)
        prof.pop()
		
		-- Add gravity
        obj.speed[2] = obj.speed[2] + (obj.gravity or VAR("gravity")) * 0.5 * dt
        -- Cap speed[2]
        obj.speed[2] = math.min((obj.maxSpeedY or VAR("maxYSpeed")), obj.speed[2])
        
        local oldX, oldY = obj.x, obj.y
        
        obj.x = obj.x + obj.speed[1] * dt
        obj.y = obj.y + obj.speed[2] * dt
        
        self:checkPortaling(obj, oldX, oldY)
        
        local oldX, oldY = obj.x, obj.y
        
        prof.push("Collisions")
        obj:checkCollisions()
        prof.pop()
        
        self:checkPortaling(obj, oldX, oldY)
        
		-- Add gravity again
        obj.speed[2] = obj.speed[2] + (obj.gravity or VAR("gravity")) * 0.5 * dt
        -- Cap speed[2]
        obj.speed[2] = math.min((obj.maxSpeedY or VAR("maxYSpeed")), obj.speed[2])
    end
    prof.pop()
end

function World:checkPortaling(obj, oldX, oldY)
    for _, p in ipairs(self.portals) do
        if p.open then
            local iX, iY = linesIntersect(oldX+obj.width/2, oldY+obj.height/2, obj.x+obj.width/2, obj.y+obj.height/2, p.x1, p.y1, p.x2, p.y2)
            
            if iX then
                local x, y, velocityX, velocityY = obj.x+obj.width/2, obj.y+obj.height/2, obj.groundSpeedX, obj.speed[2]
                local angle = math.atan2(velocityY, velocityX)
                local speed = math.sqrt(velocityX^2+velocityY^2)
                
                local outX, outY, outAngle, angleDiff, reversed = self:doPortal(p, x, y, angle)
                
                obj.x = outX
                obj.y = outY
                
                obj.groundSpeedX = math.cos(outAngle)*speed
                obj.speed[2] = math.sin(outAngle)*speed
                
                obj.angle = obj.angle + angleDiff
                
                if reversed then
                    obj.animationDirection = -obj.animationDirection
                end
                
                if VAR("portalVectorDebug") then
                    self.portalVectorDebugs = {}
                    table.insert(self.portalVectorDebugs, {
                        inX = x,
                        inY = y,
                        inVX = velocityX,
                        inVY = velocityY,
                        
                        outX = obj.x,
                        outY = obj.y,
                        outVX = obj.groundSpeedX,
                        outVY = obj.speed[2],
                        
                        reversed = reversed
                    })
                end

                obj.x = obj.x-obj.width/2
                obj.y = obj.y-obj.height/2
                    
                return true
            end
        end
    end
    
    return false
end

function World:draw()
    prof.push("Map")
    -- Map
    local lx, ty = self:cameraToMap(0, 0)
    local rx, by = self:cameraToMap(CAMERAWIDTH, CAMERAHEIGHT)
    local xStart = lx-1
    local xEnd = rx

    local yStart = ty-1
    local yEnd = by
    
    xStart = math.clamp(xStart, 1, self.width)
    yStart = math.clamp(yStart, 1, self.height)
    xEnd = math.clamp(xEnd, 1, self.width)
    yEnd = math.clamp(yEnd, 1, self.height)

    for x = xStart, xEnd do
        for y = yStart, yEnd do
            if self:inMap(x, y) then
                local tile = self:getTile(x, y)
                if tile then
                    tile:draw((x-1)*self.tileSize, (y-1)*self.tileSize)
                end
            end
        end
    end
    prof.pop()

    prof.push("Portals Back")
    -- Portals (background)
    for _, v in ipairs(self.portals) do
        v:draw("background")
    end
    prof.pop()
    
    prof.push("Objects")
    -- Objects
    love.graphics.setColor(1, 1, 1)
    
    for _, obj in ipairs(self.objects) do
        local x, y = obj.x+obj.width/2, obj.y+obj.height/2
        
        local quadX = obj.x+obj.width/2-obj.centerX
        local quadY = obj.y+obj.height/2-obj.centerY
        local quadWidth = obj.sizeX
        local quadHeight = obj.sizeY

        -- Portal duplication
        for _, p in ipairs(self.portals) do
            if p.open then
                if  rectangleOnLine(quadX, quadY, quadWidth, quadHeight, p.x1, p.y1, p.x2, p.y2) and 
                    objectWithinPortalRange(p, x, y) then
                    local angle = math.atan2(obj.speed[2], obj.groundSpeedX)
                    local cX, cY, cAngle, angleDiff, reversed = self:doPortal(p, obj.x+obj.width/2, obj.y+obj.height/2, obj.angle)
                    
                    local xScale = 1
                    if reversed then
                        xScale = -1
                    end
                    
                    love.graphics.stencil(function() p.connectsTo:stencilRectangle("out") end, "replace")
                    love.graphics.setStencilTest("greater", 0)

                    if VAR("stencilDebug") then
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
                    
                    if VAR("doPortalDebug") then
                        love.graphics.rectangle("fill", cX-.5, cY-.5, 1, 1)
                    end
                end
            end
        end

        -- Actual position
        love.graphics.stencil(function()
            for _, p in ipairs(self.portals) do
                if p.open then
                    if  rectangleOnLine(quadX, quadY, quadWidth, quadHeight, p.x1, p.y1, p.x2, p.y2) and 
                        objectWithinPortalRange(p, x, y) then
                        
                        p:stencilRectangle("in")
                    end
                end
            end
        end)

        if VAR("stencilDebug") then
            love.graphics.setStencilTest("greater", 0)
            love.graphics.setColor(1, 0, 0)
            love.graphics.draw(debugCandyImg, debugCandyQuad, self.camera:worldCoords(0, 0))
            love.graphics.setColor(1, 1, 1)
        end
        
        love.graphics.setStencilTest("equal", 0)
        
        drawObject(obj, x, y, obj.angle or 0, obj.animationDirection or 1, 1, obj.centerX, obj.centerY)
        
        love.graphics.setStencilTest()
        
        if VAR("quadDebug") then
            love.graphics.rectangle("line", quadX, quadY, quadWidth, quadHeight)
        end
	end
    prof.pop()
    
    prof.push("Portals Front")
    -- Portals (Foreground)
    for _, v in ipairs(self.portals) do
        v:draw("foreground")
    end
    prof.pop()
    
    -- Debug
    prof.push("Debug")
	if VAR("physicsDebug") then
		self:physicsDebug()
    end
    
	if VAR("advancedPhysicsDebug") then
		self:advancedPhysicsDebug()
    end
    
    if VAR("portalVectorDebug") then
        self:portalVectorDebug()
    end
    prof.pop()
end

function drawObject(obj, x, y, r, sx, sy, cx, cy)
    if type(obj.img) == "table" then
        for i, v in ipairs(obj.img) do
            if obj.palette[i] then
                love.graphics.setColor(obj.palette[i])
            end
            love.graphics.draw(v, obj.quad, x, y, r, sx, sy, cx, cy)
            love.graphics.setColor(1, 1, 1)
        end
        
        if obj.img["static"] then
            love.graphics.draw(obj.img["static"], obj.quad, x, y, r, sx, sy, cx, cy)
        end
    else
        love.graphics.draw(obj.img, obj.quad, x, y, r, sx, sy, cx, cy)
    end
end

function World:addObject(PhysObj)
	table.insert(self.objects, PhysObj)
	PhysObj.World = self
end

function World:loadMap(data)
    self.map = {}
    
    -- load any used tilemaps
    self.tileMaps = {}
    self.tileLookup = {}
    
    for i, v in pairs(data.tileMaps) do
        self.tileMaps[i] = Physics3.TileMap:new("tilemaps/" .. i, i)
        
        for j, w in pairs(v) do
            self.tileLookup[tonumber(j)] = self.tileMaps[i].tiles[w]
        end
    end
    
    
    self.width = #data.map
	self.height = #data.map[1]
    
    for x = 1, #data.map do
        self.map[x] = {}
        for y = 1, #data.map[1] do
            local mapTile = data.map[x][y]
            
            if mapTile ~= 0 then
                local tile = self.tileLookup[mapTile]
                
                if not tile then
                    print("Couldn't load real tile for \"" .. mapTile .. "\"")
                    error("Wew that map didn't load so well, did it")
                end
                
                local realY = self.height-y+1
                self.map[x][realY] = tile
            end
        end
    end
end

function World:saveMap(outPath)
    local out = {}
    
    -- build the lookup table
    local lookUp = {}
    
    for y = 1, self.height do
        for x = 1, self.width do
            local tile = self:getTile(x, y)
            
            if tile then
                -- See if the tile is already in the table
                local found = false
                
                for i, v in ipairs(lookUp) do
                    if v.tileNum == tile.num and v.tileMap == tile.tileMap then
                        found = i
                        break
                    end
                end
                
                if found then
                    lookUp[found].count = lookUp[found].count + 1
                else
                    table.insert(lookUp, {tileMap = tile.tileMap, tileNum = tile.num, count = 1})
                end
            end
        end
    end
    
    out.tileMaps = {}
    local tileMapLookUp = {}
    
    table.sort(lookUp, function(a, b) return a.count > b.count end)
    
    for j, w in ipairs(lookUp) do
        if not out.tileMaps[w.tileMap.name] then
            out.tileMaps[w.tileMap.name] = {}
            tileMapLookUp[w.tileMap.name] = {}
        end

        out.tileMaps[w.tileMap.name][tostring(j)] = w.tileNum
        tileMapLookUp[w.tileMap.name][w.tileNum] = j
    end
    
    -- build map based on lookup
    out.map = {}
    
    for x = 1, self.width do
        out.map[x] = {}
        
        for y = 1, self.height do
            local tile = self:getTile(x, y)
            if tile then
                local tileMap = tile.tileMap.name
                local tileNum = tile.num
                
                local found = false
                
                out.map[x][self.height-y+1] = tileMapLookUp[tileMap][tileNum]
            else
                out.map[x][self.height-y+1] = 0
            end
        end
    end
    
    -- Entities
    out.entities = {}
    
    table.insert(out.entities, {type="spawn", x=self.spawnX, y=self.spawnY})
    
    local outJson = JSON:encode(out)
    
    love.filesystem.write(outPath, outJson)
end

function World:physicsDebug()
    love.graphics.setColor(1, 1, 1)

	-- for x = 1, #self.map do
    --     for y = 1, #self.map[x] do
    --         if self:objVisible((x-1)*self.tileSize, (y-1)*self.tileSize, 16, 16) then
    --             local tile = self:getTile(x, y)
                
    --             if tile and tile.collision then
    --                 if tile.collision ~= VAR("tileTemplates").cube then -- optimization for cubes
    --                     local points = {}
    --                     for i = 1, #tile.collision, 2 do
    --                         table.insert(points, tile.collision[i]+(x-1)*self.tileSize)
    --                         table.insert(points, tile.collision[i+1]+(y-1)*self.tileSize)
    --                     end
                        
    --                     worldPolygon("line", unpack(points))
    --                 else
    --                     love.graphics.rectangle("line", (x-1)*self.tileSize, (y-1)*self.tileSize, 1*self.tileSize, 1*self.tileSize)
    --                 end
    --             end
    --         end
    --     end
    -- end
    
	for i, v in ipairs(self.objects) do
		v:debugDraw()
	end
end

function World:advancedPhysicsDebug()
    if not self.advancedPhysicsDebugImg or true then
        self.advancedPhysicsDebugImgData = love.image.newImageData(CAMERAWIDTH, CAMERAHEIGHT)
        
        for x = 0, CAMERAWIDTH-1 do
            for y = 0, CAMERAHEIGHT-1 do
                local worldX = math.round(self.camera.x-CAMERAWIDTH/2+x)
                local worldY = math.round(self.camera.y-CAMERAHEIGHT/2+y)
                if self:checkMapCollision(worldX, worldY, self.marios[1]) then
                    self.advancedPhysicsDebugImgData:setPixel(x, y, 1, 1, 1, 1)
                end
            end
        end
        
        self.advancedPhysicsDebugImg = love.graphics.newImage(self.advancedPhysicsDebugImgData)
    end
    
    love.graphics.draw(self.advancedPhysicsDebugImg, math.round(self.camera.x-CAMERAWIDTH/2), math.round(self.camera.y-CAMERAHEIGHT/2))
end

function World:portalVectorDebug()
    for _, v in ipairs(self.portalVectorDebugs) do
        if not v.reversed then
            love.graphics.setColor(1, 1, 0)
        else
            love.graphics.setColor(1, 0, 0)
        end
        
        worldArrow(v.inX, v.inY, v.inVX, v.inVY)
        worldArrow(v.outX, v.outY, v.outVX, v.outVY)
    end
end

function World:checkMapCollision(x, y, obj)
    if obj then
        -- Portal hijacking
        for _, p in ipairs(self.portals) do
            if p.open and objectWithinPortalRange(p, obj.x+obj.width/2, obj.y+obj.height/2) then
                -- check if pixel is inside portal wallspace
                -- rotate x, y around portal origin
                local nx, ny = pointAroundPoint(x, y, p.x1, p.y1, -p.angle)

                nx, ny = math.round(nx), math.round(ny)
                
                if ny > p.y1-1 then
                    if  ny > p.y1-1 and
                        nx >= p.x1+1 and nx <= p.x1+p.size then
                        return false
                        
                    elseif
                        (nx < p.x1+1 or nx > p.x1+p.size) then
                        if ny <= p.y1+1 then
                            return true
                        else
                            return false
                        end
                    end
                end
            end
        end
    end
    
    local tileX, tileY = self:worldToMap(x, y)
	
	if not self:inMap(tileX, tileY) then
		return false
    end
    
    local tile = self:getTile(tileX, tileY)
    
    if tile then
        local inTileX = math.fmod(x, self.tileSize)
        local inTileY = math.fmod(y, self.tileSize)
        
        return tile:checkCollision(inTileX, inTileY)
    else
        return col
    end
end

function World:setMap(x, y, i)
    if self:inMap(x, y) then
        self.map[x][y] = i
    end
end

function World:getTile(x, y)
    return self.map[x][y]
end

function World:inMap(x, y)
    return x > 0 and x <= self.width and y > 0 and y <= self.height
end

function World:rayCast(x, y, dir) -- Uses code from http://lodev.org/cgtutor/raycasting.html , thanks man
    -- Todo: limit how far offscreen this goes?
    -- Todo: allow offscreen as long as it'll return to inscreen
    local rayPosX = x+1
    local rayPosY = y+1
    local rayDirX = math.cos(dir)
    local rayDirY = math.sin(dir)
    
    local mapX = math.floor(rayPosX)
    local mapY = math.floor(rayPosY)

    -- length of ray from one x or y-side to next x or y-side
    local deltaDistX = math.sqrt(1 + (rayDirY * rayDirY) / (rayDirX * rayDirX))
    local deltaDistY = math.sqrt(1 + (rayDirX * rayDirX) / (rayDirY * rayDirY))

    -- what direction to step in x or y-direction (either +1 or -1)
    local stepX, stepY

    local hit = false -- was there a wall hit?
    local side -- was a NS or a EW wall hit?
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

    -- perform DDA
    while not hit do
        -- Check if ray has hit something (or went outside the map)
        local cubeCol = false
        
        if not self:inMap(mapX, mapY) then
            cubeCol = true
        else
            local tile = self:getTile(mapX, mapY)
            if tile and tile.collision then
                if tile.collision == VAR("tileTemplates").cube then
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
                        return mapX, mapY, col.x, col.y, col.side
                    end
                end
            end
        end
        
        if cubeCol then
            local absX = mapX-1
            local absY = mapY-1

            if side == "ver" then
                local dist = (mapX - rayPosX + (1 - stepX) / 2) / rayDirX;
                hitDist = rayPosY + dist * rayDirY - math.floor(mapY)

                absY = absY + hitDist
            else
                local dist = (mapY - rayPosY + (1 - stepY) / 2) / rayDirY;
                hitDist = rayPosX + dist * rayDirX - math.floor(mapX)

                absX = absX + hitDist
            end

            if side == "ver" then
                if stepX > 0 then
                    side = 4
                else
                    side = 2
                    absX = absX + 1
                end
            else
                if stepY > 0 then
                    side = 1
                else
                    side = 3
                    absY = absY + 1
                end
            end

            return mapX, mapY, absX, absY, side
        elseif polyCol then
            
            return mapX, mapY, absX, absY, side
        end
        -- jump to next map square, OR in x-direction, OR in y-direction
        if sideDistX < sideDistY then
            sideDistX = sideDistX + deltaDistX
            mapX = mapX + stepX;
            side = "ver";
        else
            sideDistY = sideDistY + deltaDistY
            mapY = mapY + stepY
            side = "hor"
        end
    end
end

function World:mapToWorld(x, y)
    return x*self.tileSize, y*self.tileSize
end

function World:mapToCamera(x, y)
    local x, y = self:mapToWorld(x, y)
    return self.camera:cameraCoords(x, y)
end

function World:worldToMap(x, y)
    return math.floor(x/self.tileSize)+1, math.floor(y/self.tileSize)+1
end

function World:cameraToMap(x, y)
    return self:worldToMap(self:cameraToWorld(x, y))
end

function World:cameraToWorld(x, y)
    return self.camera:worldCoords(x, y)
end

function World:mouseToWorld()
    local x, y = self:getMouse()

    return self.camera:worldCoords(x, y)
end

function World:mouseToMap()
    local x, y = self:getMouse()
    
    return self:cameraToMap(x, y)
end

function World:getMouse()
    local x, y = love.mouse.getPosition()
    return x/VAR("scale"), y/VAR("scale")
end

function World:getMapRectangle(x, y, w, h, clamp)
    local lx, rx, ty, by
    
    if w < 0 then
        x = x + w
        w = -w
    end
    
    if h < 0 then
        y = y + h
        h = -h
    end
    
    lx, ty = self:worldToMap(x+8, y+8)
    rx, by = self:worldToMap(x+w-8, y+h-8)
    
    if clamp then
        if lx > self.width or rx < 1 or ty > self.height or by < 1 then -- selection is completely outside map
            return {}
        end
        
        lx = math.max(lx, 1)
        rx = math.min(rx, self.width)
        ty = math.max(ty, 1)
        by = math.min(by, self.height)
    end
    
    return lx, rx, ty, by
end

function World:attemptPortal(tileX, tileY, side, x, y, color, ignoreP)
    local x1, y1, x2, y2 = self:checkPortalSurface(tileX, tileY, side, x, y, ignoreP)
    
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
            
            local p1x = math.cos(angle+math.pi)*VAR("portalSize")/2+mX
            local p1y = math.sin(angle+math.pi)*VAR("portalSize")/2+mY
            
            local p2x = math.cos(angle)*VAR("portalSize")/2+mX
            local p2y = math.sin(angle)*VAR("portalSize")/2+mY
            
            local portal = Portal:new(self, p1x, p1y, p2x, p2y, color)
            table.insert(self.portals, portal)
            
            return portal
        end
    end
end

function World:doPortal(portal, x, y, angle)
    -- Check whether to reverse portal direction (when portal face the same way)
    local reversed = false
    
    if  portal.angle+math.pi < portal.connectsTo.angle+math.pi+VAR("portalReverseRange") and
        portal.angle+math.pi > portal.connectsTo.angle+math.pi-VAR("portalReverseRange") then
        reversed = true
    end
    
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
    local newX, newY
    
    if not reversed then
        -- Rotate around entry portal (+ half a turn)
        newX, newY = pointAroundPoint(x, y, portal.x2, portal.y2, -portal.angle-math.pi)
        
        -- Translate by portal offset (from opposite sides)
        newX = newX + (portal.connectsTo.x1 - portal.x2)
        newY = newY + (portal.connectsTo.y1 - portal.y2)
    else
        -- Rotate around entry portal
	    newX, newY = pointAroundPoint(x, y, portal.x1, portal.y1, -portal.angle)

        -- mirror along entry portal
        newY = newY + (portal.y1-newY)*2
    
        -- Translate by portal offset
        newX = newX + (portal.connectsTo.x1 - portal.x1)
        newY = newY + (portal.connectsTo.y1 - portal.y1)
    end

	-- Rotate around exit portal
    newX, newY = pointAroundPoint(newX, newY, portal.connectsTo.x1, portal.connectsTo.y1, portal.connectsTo.angle)

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

local function walkSide(self, tile, tileX, tileY, side, dir)
    local nextX, nextY, angle, nextAngle, nextTileX, nextTileY, nextSide, x, y
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
                
                if self:inMap(checkTileX, checkTileY) then
                    checkTile = self:getTile(checkTileX, checkTileY)
                end
                
                nextTileX = tileX + moveX
                nextTileY = tileY + moveY
                
                x = nextX - moveX*self.tileSize
                y = nextY - moveY*self.tileSize
                
                tileX = nextTileX
                tileY = nextTileY
                
                if not checkTile or not checkTile.collision then
                    --check if next tile has a point on the same spot as nextX/nextY
                    if self:inMap(tileX, tileY) then
                        local nextTile = self:getTile(tileX, tileY)
                        if nextTile and nextTile.collision then
                            local points = nextTile.collision
                            
                            for i = 1, #points, 2 do
                                if points[i] == x and points[i+1] == y then
                                    -- Make sure the angle of this side is the same
                                    found = true
                                    side = (i+1)/2
                                    tile = nextTile
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

function World:checkPortalSurface(tileX, tileY, side, worldX, worldY, ignoreP)
    if not self:inMap(tileX, tileY) then
        return false
    end
    
    local tile = self:getTile(tileX, tileY)
    
    if not tile or not tile.collision then
        return false
    end
    
    local startX, startY = walkSide(self, tile, tileX, tileY, side, "anticlockwise")
    local endX, endY = walkSide(self, tile, tileX, tileY, side, "clockwise")
    
    startX, startY = self:mapToWorld(startX, startY)
    endX, endY = self:mapToWorld(endX, endY)
    
        
    -- Do some magic to determine whether there's portals blocking off sections of our portal surface
    local angle = math.atan2(endY-startY, endX-startX)
        
    for _, p in ipairs(self.portals) do
        if p ~= ignoreP then
            if math.abs(p.angle - angle) < 0.0001 then -- angle is the same!
                local onLine = pointOnLine(p.x1, p.y1, p.x2, p.y2, worldX, worldY)
                if onLine then -- surface is the same! (or at least on the same line which is good enough)
                    if onLine >= 0 then -- Check on which side of the same surface portal we are
                        if math.abs(startX-worldX) > math.abs(p.x2-worldX) or
                            math.abs(startY-worldY) > math.abs(p.y2-worldY) then -- finally check that we are not accidentally lengthening the portal surface
                            startX = p.x2
                            startY = p.y2
                        end
                        
                    else
                        if math.abs(endX-worldX) > math.abs(p.x1-worldX) or
                            math.abs(endY-worldY) > math.abs(p.y1-worldY) then
                            endX = p.x1
                            endY = p.y1
                        end
                    end
                end
            end
        end
    end

    return startX, startY, endX, endY, angle
end

function World:getFloodArea(x, y)
    local targetTile = self:getTile(x, y)
    local tileLookupTable = {}
    
    for x = 1, self.width do
        tileLookupTable[x] = {}
    end
    
    stack = {{x, y}}
    
    repeat
        cur = table.remove(stack, 1)
        
        if  self:inMap(cur[1], cur[2]) and 
            not tileLookupTable[cur[1]][cur[2]] and
            self:getTile(cur[1], cur[2]) == targetTile then
                
            tileLookupTable[cur[1]][cur[2]] = true
            
            table.insert(stack, {cur[1]-1, cur[2]})
            table.insert(stack, {cur[1]+1, cur[2]})
            table.insert(stack, {cur[1], cur[2]-1})
            table.insert(stack, {cur[1], cur[2]+1})
        end
    until #stack == 0
    
    local tileTable = {}
    
    for y = 1, self.height do
        for x = 1, self.width do
            if tileLookupTable[x][y] then
                table.insert(tileTable, {x, y})
            end
        end
    end
    
    return tileTable
end

function World:expandMapTo(x, y)
    local moveStuff = {0, 0}
    
    if x > self.width then
        for newX = self.width+1, x do
            self.map[newX] = {}
        end
        
        self.width = x
    end
    
    if x <= 0 then
        local newColumns = -x+1
        
        self.width = self.width+newColumns
        
        for newX = self.width, newColumns+1, -1 do
            self.map[newX] = self.map[newX-newColumns]
        end
        
        for newX = 1, newColumns do
            self.map[newX] = {}
        end
        
        moveStuff[1] = newColumns
    end
    
    if y > self.height then
        self.height = y
    end
    
    if y <= 0 then
        local newRows = -y+1
        
        self.height = self.height+newRows
        
        for newY = self.height, newRows+1, -1 do
            for lx = 1, self.width do
                self.map[lx][newY] = self.map[lx][newY-newRows]
            end
        end
        
        for newY = 1, newRows do
            for lx = 1, self.width do
                self.map[lx][newY] = nil
            end
        end
        
        moveStuff[2] = newRows
    end
    
    self.camera.x = self.camera.x+moveStuff[1]*16
    self.camera.y = self.camera.y+moveStuff[2]*16
        
    for _, v in ipairs(self.objects) do
        v.x = v.x + moveStuff[1]*16
        v.y = v.y + moveStuff[2]*16
    end

    return moveStuff[1], moveStuff[2], moveStuff[1]*16, moveStuff[2]*16
end

return World