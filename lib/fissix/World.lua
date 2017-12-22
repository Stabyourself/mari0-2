local World = class("fissix.World")

function World:initialize(tileMap)
	self.tileMap = tileMap
    self.tileSize = self.tileMap.tileSize
	
	self.objects = {}
	self.map = {}
end

function World:addObject(PhysObj)
	table.insert(self.objects, PhysObj)
	PhysObj.World = self
end

function World:loadMap(map)
	self.map = map

    self.width = #self.map[1]
	self.height = #self.map[1][1]
end

function World:update(dt)
	for i, v in ipairs(self.objects) do
		v:update(dt)
		
		-- Add gravity
        v.speedY = math.min((v.maxSpeedY or MAXYSPEED), v.speedY + (v.gravity or GRAVITY) * 0.5 * dt)
        
        local oldX, oldY = v.x, v.y
        
		v.x = v.x + v.speedX * dt
		v.y = v.y + v.speedY * dt
		
		v:checkCollisions()
        
        -- Portal checks
		for _, p in ipairs(self.portals) do
			local iX, iY = linesIntersect(oldX+v.width/2, oldY+v.height/2, v.x+v.width/2, v.y+v.height/2, p.x1, p.y1, p.x2, p.y2)
			if iX then
				self:doPortal(v, p, oldX, oldY)
				break
			end
		end
		
		-- Add gravity again
		v.speedY = math.min((v.maxSpeedY or MAXYSPEED), v.speedY + (v.gravity or GRAVITY) * 0.5 * dt)
	end
end

function World:draw()
	for _, obj in ipairs(self.objects) do
		mainPerformanceTracker:track("worldobjects drawn")
		worldDraw(obj.img, obj.quad, obj.x+obj.width/2, obj.y+obj.height/2, obj.r or 0, obj.animationDirection or 1, 1, obj.centerX, obj.centerY)
	end

	if PHYSICSDEBUG then
		self:physicsDebug()
    end
end

function World:checkMapCollision(x, y)
    local tileX, tileY = self:worldToMap(x, y)
	
	if not self:inMap(tileX, tileY) then
		return false
    end
    
	local inTileX = math.fmod(x, self.tileSize)
	local inTileY = math.fmod(y, self.tileSize)
	
	local col = self:getTile(tileX, tileY):checkCollision(inTileX, inTileY)
	
	return col
end

function World:physicsDebug()
	for x = 1, #self.map[1] do
        for y = 1, #self.map[1][x] do
            if self:objVisible(x, y, 1, 1) then
                local tile = self:getTile(x, y)
                
                if tile.collision then
                    if type(tile.collision) == "table" then
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

function World:getTile(x, y, i)
    return self.tileMap.tiles[self.map[i or 1][x][y]]
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

        -- Check if ray has hit something (or went outside the map)
        if not self:inMap(mapX, mapY) or self:getTile(mapX, mapY).collision then
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
                    side = "left"
                else
                    side = "right"
                    absX = absX + 1
                end
            else
                if stepY > 0 then
                    side = "top"
                else
                    side = "bottom"
                    absY = absY + 1
                end
            end

            return mapX, mapY, absX, absY, side
        end
    end
end

function World:mapToWorld(x, y)
    return x*self.tileSize, y*self.tileSize
end

function World:worldToMap(x, y)
    return math.floor(x/self.tileSize)+1, math.floor(y/self.tileSize)+1
end

function World:doPortal(obj, portal, oldX, oldY)
	-- Modify speed
    local speed = math.sqrt(obj.speedX^2 + obj.speedY^2)
    local r = portal.connectsTo.r - math.atan2(obj.speedY, obj.speedX) + portal.r
    
	obj.speedX = math.cos(r)*speed
	obj.speedY = math.sin(r)*speed

	-- Modify position
    -- Rotate around entry portal
	local newX, newY = pointAroundPoint(oldX+obj.width/2, oldY+obj.height/2, portal.x1, portal.y1, -portal.r)
    
	-- Translate by portal offset
	newX = newX + (portal.connectsTo.x1 - portal.x1)
	newY = newY + (portal.connectsTo.y1 - portal.y1)

	-- Rotate around exit portal
	newX, newY = pointAroundPoint(newX, newY, portal.connectsTo.x1, portal.connectsTo.y1, portal.connectsTo.r)

	obj.x = newX-obj.width/2
    obj.y = newY-obj.height/2
    
end

return World