Level = class("Level", fissix.World)

function Level:initialize(path, tileMap)
    local levelCode = love.filesystem.read(path)
    self.data = sandbox.run(levelCode)
    self.tileMap = tileMap

    fissix.World.initialize(self, tileMap)
    self:loadMap(self.data.map)
    
    self.backgroundColor = self.data.backgroundColor or {92, 148, 252}

    self.enemyList = loadEnemies()
    
    self.blocks = {}
    self.liveReplacements = {}
    for x = 1, self.width do
        for y = 1, self.height do
            local tile = self:getTile(x, y)
            if tile and tile.type == "coinAnimation" then
                table.insert(self.liveReplacements, {
                    x = x,
                    y = y
                })
            end
        end
    end
    
    self.blockBounces = {}
    
    self.spawnList = {}
    -- Parse entities
    for _, v in ipairs(self.data.entities) do
        local enemy = self.enemyList[v.type]

        if enemy and not NOENEMIES then -- is enemy
            table.insert(self.spawnList, {
                enemy = enemy,
                x = v.x,
                y = v.y
            })
        elseif v.type == "spawn" then
            self.spawnX = v.x
            self.spawnY = v.y
        end
    end

    table.sort(self.spawnList, function(a, b) return a.x<b.x end)

    self.marios = {}

    local x, y = self:mapToWorld(self.spawnX, self.spawnY)
    
    table.insert(self.marios, Mario:new(self, smb3_mario, x-6, y-12))

    self.portals = {}
    
    -- Camera stuff
    self.camera = Camera:new()
    self.spawnLine = 0
    self.spawnI = 1

    self:spawnEnemies(self.camera.x+WIDTH+ENEMIESPSAWNAHEAD+2)
end

function Level:update(dt)
    updateGroup(self.blockBounces, dt)
    fissix.World.update(self, dt)
    self:updateCamera(dt)

    local newSpawnLine = self.camera.x/self.tileSize+WIDTH+ENEMIESPSAWNAHEAD+2
    if newSpawnLine > self.spawnLine then
        self:spawnEnemies(newSpawnLine)
    end
end

function Level:draw()
    self.camera:attach()
    
    local xStart = math.floor(self.camera.x/self.tileSize)+1
    local xEnd = math.min(self.width, xStart+WIDTH)
    xEnd = math.min(self.width, xEnd)

    local yStart = 1
    local yEnd = HEIGHT
    
    self.drawList = {}
    
    for x = xStart, xEnd do
        for y = yStart, yEnd do
            local Tile = self:getTile(x, y)
            
            if Tile and not Tile.invisible then
                Tile:draw((x-1)*self.tileMap.tileSize, (y-1)*self.tileMap.tileSize)
            end
        end
    end
    
    for _, v in ipairs(self.marios) do
        love.graphics.line(v.x+v.width/2, v.y+v.height/2+2, v.crosshairX, v.crosshairY)
    end
    

    fissix.World.draw(self)
    for _, v in ipairs(self.portals) do
        v:draw()
    end
    
    self.camera:detach()
end

function Level:keypressed(key)
    if key == CONTROLS.jump and self.marios[1].onGround then
        self.marios[1]:jump()
    end
    
    if key == CONTROLS.boost then
        self.marios[1].speedX = 1000
    end
end

function Level:mousepressed(x, y, button)
    self:attemptPortal(1, button)
end

function Level:attemptPortal(ply, portalI)
    local mario = self.marios[ply]
    local x1, y1, x2, y2 = self:checkPortalSurface(mario.crosshairTileX, mario.crosshairTileY, mario.crosshairSide, 0)
    
    if x1 then
        -- make sure that the surface is big enough to hold a portal
        local angle = math.atan2(y2-y1, x2-x1)
        local length = math.sqrt((x1-x2)^2+(y1-y2)^2)
        
        if length >= PORTALSIZE then
            local middleProgress = math.sqrt((mario.crosshairX-x1)^2+(mario.crosshairY-y1)^2)/length
            
            local leftSpace = middleProgress*length
            local rightSpace = (1-middleProgress)*length
            
            if leftSpace < PORTALSIZE/2 then -- move final portal position to the right
                middleProgress = (PORTALSIZE/2/length)
            elseif rightSpace < PORTALSIZE/2 then -- move final portal position to the left
                middleProgress = 1-(PORTALSIZE/2/length)
            end
            
            local mX = x1 + (x2-x1)*middleProgress
            local mY = y1 + (y2-y1)*middleProgress
            
            local p1x = math.cos(angle+math.pi)*PORTALSIZE/2+mX
            local p1y = math.sin(angle+math.pi)*PORTALSIZE/2+mY
            
            local p2x = math.cos(angle)*PORTALSIZE/2+mX
            local p2y = math.sin(angle)*PORTALSIZE/2+mY
            
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

function Level:spawnEnemies(untilX)
    while self.spawnI <= #self.spawnList and untilX > self.spawnList[self.spawnI].x do -- Spawn next enemy
        toSpawn = self.spawnList[self.spawnI]
        local x, y = self:mapToWorld(toSpawn.x-.5, toSpawn.y)
        Enemy:new(self, x, y, toSpawn.enemy.json, toSpawn.enemy.img, toSpawn.enemy.quad)

        self.spawnI = self.spawnI + 1

        -- Update untilX so enemies spawn in groups
        untilX = untilX + 2
    end

    self.spawnLine = untilX
end

function Level:updateCamera(dt)
    local pX = game.level.marios[1].x
    local pXr = pX - self.camera.x
    local pSpeedX = game.level.marios[1].speedX
    
    if WIDTH > 13 then
        -- Scroll right?
        if pXr > SCROLLINGCOMPLETE*self.tileSize then
            self.camera.x = pX - SCROLLINGCOMPLETE*self.tileSize
        elseif pXr > SCROLLINGSTART*self.tileSize and pSpeedX > SCROLLRATE then
            self.camera.x = self.camera.x + SCROLLRATE*dt
        end
        
        -- Scroll left?
        if pXr < SCROLLINGLEFTCOMPLETE*self.tileSize then
            self.camera.x = pX - SCROLLINGLEFTCOMPLETE*self.tileSize
        elseif pXr < SCROLLINGLEFTSTART*self.tileSize and pSpeedX < -SCROLLRATE then
            self.camera.x = self.camera.x - SCROLLRATE*dt
        end
    else
        self.camera.x = pX-3*self.tileSize
    end
    
    -- And clamp it to map boundaries
    self.camera.x = math.min(self.camera.x, (game.level.width - WIDTH)*self.tileSize)
    self.camera.x = math.max(self.camera.x, 0)
end

function Level:setMap(x, y, i)
    self.map[1][x][y] = i
    
    local found = false
    
    for _, v in ipairs(self.liveReplacements) do
        if v.x == x and v.y == y then
            found = true
            break
        end
    end
    
    if not found then
        table.insert(self.liveReplacements, {
            x = x,
            y = y
        })
    end
end

function Level:bumpBlock(x, y)
    local Tile = self:getTile(x, y)
    if Tile.breakable or Tile.coinBlock then
        local blockBounce = BlockBounce:new(x, y)
        
        table.insert(self.blockBounces, blockBounce)
        
        playSound(blockSound)

        if Tile.coinBlock then
            self:setMap(x, y, 113)

            playSound(coinSound)
        end
    end
end

function Level:objVisible(x, y, w, h)
    return x+w > self.camera.x/self.tileSize-OBJOFFSCREENDRAW and x < self.camera.x/self.tileSize+WIDTH+OBJOFFSCREENDRAW and
        y+h > self.camera.y/self.tileSize-OBJOFFSCREENDRAW and y < self.camera.y/self.tileSize+HEIGHT+OBJOFFSCREENDRAW
end

function Level:checkMapCollision(x, y)
    -- Portal hijacking
    for _, v in ipairs(self.portals) do
        if v.open then
            -- check if pixel is inside portal wallspace
            -- rotate x, y around portal origin
            local nx, ny = pointAroundPoint(x, y, v.x1, v.y1, -v.r)
            
            if  nx > v.x1+1 and nx < v.x1+v.size-1 and
                ny >= v.y1 and ny < v.y1+10 then
                return false
            end
        end
    end
    
    return fissix.World.checkMapCollision(self, x, y)
end

function Level:checkPortalSurface(tileX, tileY, side, progress)
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