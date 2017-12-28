local World = class("fissix.World")

function World:initialize(tileMap)
	self.tileMap = tileMap
    self.tileSize = self.tileMap.tileSize
    
    self.map = {}
	
	self.objects = {}
    self.portals = {}
    self.portalVectorDebugs = {}
end

function World:addObject(PhysObj)
	table.insert(self.objects, PhysObj)
	PhysObj.World = self
end

function World:loadMap(map)
	self.map = map

    self.width = #self.map
	self.height = #self.map[1]
end

function World:update(dt)
    for i, v in ipairs(self.objects) do
		v:update(dt)
		
		-- Add gravity
        v.speedY = v.speedY + (v.gravity or VAR("gravity")) * 0.5 * dt
        -- Cap speedY
        v.speedY = math.min((v.maxSpeedY or VAR("maxYSpeed")), v.speedY)
        
        local oldX, oldY = v.x, v.y
        
        v.x = v.x + v.speedX * dt
        v.y = v.y + v.speedY * dt
        
		v:checkCollisions()
        
        -- Portal checks
		for _, p in ipairs(self.portals) do
			local iX, iY = linesIntersect(oldX+v.width/2, oldY+v.height/2, v.x+v.width/2, v.y+v.height/2, p.x1, p.y1, p.x2, p.y2)
			if iX then
				self:doPortal(v, p, v.x, v.y, v.groundSpeedX, v.speedY, oldX, oldY)
				break
			end
        end
		
		-- Add gravity again
        v.speedY = v.speedY + (v.gravity or VAR("gravity")) * 0.5 * dt
        -- Cap speedY
        v.speedY = math.min((v.maxSpeedY or VAR("maxYSpeed")), v.speedY)
	end
end

function World:draw()
	for _, obj in ipairs(self.objects) do
		worldDraw(obj.img, obj.quad, obj.x+obj.width/2, obj.y+obj.height/2, obj.r or 0, obj.animationDirection or 1, 1, obj.centerX, obj.centerY)
	end
    
    for _, v in ipairs(self.portals) do
        v:draw()
    end

	if VAR("physicsDebug") then
		self:physicsDebug()
    end
    
    if VAR("portalVectorDebug") then
        self:portalVectorDebug()
    end
end

function World:physicsDebug()
	for x = 1, #self.map do
        for y = 1, #self.map[x] do
            if self:objVisible((x-1)*self.tileSize, (y-1)*self.tileSize, 16, 16) then
                local tile = self:getTile(x, y)
                
                if tile.collision then
                    if tile.collision ~= VAR("collision").cube then -- optimization for cubes
                        local points = {}
                        for i = 1, #tile.collision, 2 do
                            table.insert(points, tile.collision[i]/self.tileSize+x-1)
                            table.insert(points, tile.collision[i+1]/self.tileSize+y-1)
                        end
                        
                        worldPolygon("line", unpack(points))
                    else
                        worldRectangle("line", x-1, y-1, 1, 1)
                    end
                end
            end
        end
    end
    
	for i, v in ipairs(self.objects) do
		v:debugDraw()
	end
end

function World:portalVectorDebug()
    for _, v in ipairs(self.portalVectorDebugs) do
        if not v.reversed then
            love.graphics.setColor(255, 255, 0)
        else
            love.graphics.setColor(255, 0, 0)
        end
        
        worldArrow(v.inX, v.inY, v.inVX, v.inVY)
        worldArrow(v.outX, v.outY, v.outVX, v.outVY)
    end
end

function World:checkMapCollision(x, y)
    -- Portal hijacking
    for _, v in ipairs(self.portals) do
        if v.open then
            -- check if pixel is inside portal wallspace
            -- rotate x, y around portal origin
            local nx, ny = pointAroundPoint(x, y, v.x1, v.y1, -v.r)
            
            if  nx > v.x1+1 and nx < v.x1+v.size-1 and
                ny >= v.y1-1 and ny < v.y1+10 then
                return false
            end
        end
    end
    
    local tileX, tileY = self:worldToMap(x, y)
	
	if not self:inMap(tileX, tileY) then
		return false
    end
    
	local inTileX = math.fmod(x, self.tileSize)
    local inTileY = math.fmod(y, self.tileSize)
    
	local col = self:getTile(tileX, tileY):checkCollision(inTileX, inTileY)
	
	return col
end

function World:setMap(x, y, i)
    self.map[1][x][y] = i
end

function World:getTile(x, y)
    return self.tileMap.tiles[self.map[x][y]]
end

function World:inMap(x, y)
    return x > 0 and x <= self.width and y > 0 and y <= self.height
end

function World:rayCast(x, y, dir) -- Uses code from http://lodev.org/cgtutor/raycasting.html , thanks man
    -- Todo: limit how far offscreen this goes?
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
            if tile.collision then
                if tile.collision == VAR("collision").cube then
                    cubeCol = true
                else
                
                    -- complicated polygon stuff
                    local col
                        
                    -- Trace line
                    local t1x, t1y = x, y
                    local t2x, t2y = x+math.cos(dir)*100000, y+math.sin(dir)*100000
                    
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
                hitDist = math.fmod(rayPosY + dist * rayDirY, 1)

                absY = absY + hitDist
            else
                local dist = (mapY - rayPosY + (1 - stepY) / 2) / rayDirY;
                hitDist = math.fmod(rayPosX + dist * rayDirX, 1)

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

function World:worldToMap(x, y)
    return math.floor(x/self.tileSize)+1, math.floor(y/self.tileSize)+1
end

function World:attemptPortal(ply, portalI)
    local mario = self.marios[ply]
    local x1, y1, x2, y2 = self:checkPortalSurface(mario.crosshairTileX, mario.crosshairTileY, mario.crosshairSide, 0)
    
    if x1 then
        -- make sure that the surface is big enough to hold a portal
        local angle = math.atan2(y2-y1, x2-x1)
        local length = math.sqrt((x1-x2)^2+(y1-y2)^2)
        
        if length >= VAR("portalSize") then
            local middleProgress = math.sqrt((mario.crosshairX-x1)^2+(mario.crosshairY-y1)^2)/length
            
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
            
            local portal = Portal:new(self, p1x, p1y, p2x, p2y, mario.portalColor[portalI])
            mario.portals[portalI] = portal
            table.insert(self.portals, portal)
            
            if mario.portals[1] and mario.portals[2] then
                mario.portals[1]:connectTo(mario.portals[2])
                mario.portals[2]:connectTo(mario.portals[1])
            end
        end
    end 
end

function World:doPortal(obj, portal, x, y, speedX, speedY, oldX, oldY)
    -- Check whether to reverse portal direction (when portal face the same way)
    local reversed = false
    
    if  portal.r+math.pi < portal.connectsTo.r+math.pi+VAR("portalReverseRange") and
        portal.r+math.pi > portal.connectsTo.r+math.pi-VAR("portalReverseRange") then
        reversed = true
    end
    
    local oldSpeedX, oldSpeedY = speedX, speedY
    
	-- Modify speed
    local speed = math.sqrt(speedX^2 + speedY^2)
    local inR = math.atan2(speedY, speedX)
    local r
    
    if not reversed then
        r = portal.connectsTo.r - portal.r - math.pi + inR
    else
        r = portal.connectsTo.r - inR + portal.r
    end
    
	obj.groundSpeedX = math.cos(r)*speed
    obj.speedY = math.sin(r)*speed
    
	-- Modify position
    -- Rotate around entry portal
    local newX, newY
    
    if not reversed then
        newX, newY = pointAroundPoint(x+obj.width/2, y+obj.height/2, portal.x2, portal.y2, -portal.r-math.pi)
        
        -- Translate by portal offset
        newX = newX + (portal.connectsTo.x1 - portal.x2)
        newY = newY + (portal.connectsTo.y1 - portal.y2)
    else
	    newX, newY = pointAroundPoint(oldX+obj.width/2, oldY+obj.height/2, portal.x1, portal.y1, -portal.r)
    
        -- Translate by portal offset
        newX = newX + (portal.connectsTo.x1 - portal.x1)
        newY = newY + (portal.connectsTo.y1 - portal.y1)
    end

	-- Rotate around exit portal
    newX, newY = pointAroundPoint(newX, newY, portal.connectsTo.x1, portal.connectsTo.y1, portal.connectsTo.r)

	obj.x = newX-obj.width/2
    obj.y = newY-obj.height/2
    
    self.portalVectorDebugs = {}
    table.insert(self.portalVectorDebugs, {
        inX = x+obj.width/2,
        inY = y+obj.height/2,
        inVX = speedX,
        inVY = speedY,
        
        outX = obj.x+obj.width/2,
        outY = obj.y+obj.height/2,
        outVX = obj.groundSpeedX,
        outVY = obj.speedY,
        
        reversed = reversed
    })
end

function World:checkPortalSurface(tileX, tileY, side, progress)
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
    
    local function walkSide(tile, tileX, tileY, side, dir)
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
                end
            end
            
            first = false
        until not found
        
        return tileX+x/self.tileSize-1, tileY+y/self.tileSize-1
    end
    
    if not self:inMap(tileX, tileY) then
        return false
    end
    
    local tile = self:getTile(tileX, tileY)
    
    if not tile or not tile.collision then
        return false
    end
    
    local startX, startY = walkSide(tile, tileX, tileY, side, "anticlockwise")
    local endX, endY = walkSide(tile, tileX, tileY, side, "clockwise")
    
    startX, startY = self:mapToWorld(startX, startY)
    endX, endY = self:mapToWorld(endX, endY)

    return startX, startY, endX, endY
end

return World