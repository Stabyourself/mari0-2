Level = class("Level")

function Level:initialize(path, tileMap)
    self.json = JSON:decode(love.filesystem.read(path))
    self.tileMap = tileMap
    
    self.map = self.json.map
    self.background = self.json.background
    self.width = #self.map
    self.height = #self.map[1]
    self.backgroundColor = self.json.backgroundColor or {92, 148, 252}

    self.enemyList = loadEnemies()
    
    self.world = World:new()
    
    self.blocks = {}
    self.liveReplacements = {}
    for x = 1, self.width do
        self.blocks[x] = {}

        for y = 1, self.height do
            if self.tileMap.tiles[self.map[x][y]] then
                if self.tileMap.tiles[self.map[x][y]].collision then
                    self.blocks[x][y] = Block:new(self.world, x, y)
                end
                
                if self.tileMap.tiles[self.map[x][y]].t == "coinblock" then
                    table.insert(self.liveReplacements, {
                        x = x,
                        y = y
                    })
                end
            end
        end
    end
    
    self.blockBounces = {}
    
    self.spawnList = {}
    -- Parse entities
    for _, v in ipairs(self.json.entities) do
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
    table.insert(self.marios, Mario:new(self.world, self.spawnX-6/16, self.spawnY-12/16))

    self.portals = {}
    table.insert(self.portals, Portal:new(self.world, 3, 11, 0, {60, 188, 252}))
    table.insert(self.portals, Portal:new(self.world, 6, 11, 0, {232, 130, 30}))

    self.portals[1].connectsTo = self.portals[2]
    self.portals[2].connectsTo = self.portals[1]
    
    -- Camera stuff
    self.camera = Camera:new()
    self.spawnLine = 0
    self.spawnI = 1

    -- Level canvases
    print("Prerendering level...")
    self.levelCanvases = {}
    for x = 0, math.floor(self.width/LEVELCANVASWIDTH) do
        --table.insert(self.levelCanvases, LevelCanvas:new(self, x*LEVELCANVASWIDTH+1))
    end

    self:spawnEnemies(self.camera.x+WIDTH+ENEMIESPSAWNAHEAD+2)
end

function Level:update(dt)
    updateGroup(self.blockBounces, dt)
    self.world:update(dt)
    self:updateCamera(dt)

    local newSpawnLine = self.camera.x+WIDTH+ENEMIESPSAWNAHEAD+2
    if newSpawnLine > self.spawnLine then
        self:spawnEnemies(newSpawnLine)
    end
end

function Level:draw()
    self.camera:attach()
    
    -- MAIN LEVELCANVAS
    --[[
    local mainCanvasI = math.floor((self.camera.x)/LEVELCANVASWIDTH)+1
    mainCanvasI = math.max(1, mainCanvasI)
    
    love.graphics.draw(self.levelCanvases[mainCanvasI].canvas, ((mainCanvasI-1)*LEVELCANVASWIDTH-OFFSCREENDRAW)*TILESIZE, 0)
    mainPerformanceTracker:track("levelcanvases drawn")
    
    -- LEFT ADDITION (for 3D)
    if math.fmod(self.camera.x, LEVELCANVASWIDTH) < OFFSCREENDRAW and mainCanvasI > 1 then
        mainPerformanceTracker:track("levelcanvases drawn")
        love.graphics.draw(self.levelCanvases[mainCanvasI-1].canvas, ((mainCanvasI-2)*LEVELCANVASWIDTH-OFFSCREENDRAW)*TILESIZE, 0)
    end
    
    -- RIGHT ADDITION (for transition to next levelCanvas and 3D)
    if math.fmod(self.camera.x, LEVELCANVASWIDTH) > LEVELCANVASWIDTH-WIDTH-OFFSCREENDRAW and mainCanvasI < #self.levelCanvases then
        mainPerformanceTracker:track("levelcanvases drawn")
        love.graphics.draw(self.levelCanvases[mainCanvasI+1].canvas, ((mainCanvasI)*LEVELCANVASWIDTH-OFFSCREENDRAW)*TILESIZE, 0)
    end--]]
    
    -- Live replacements: Coinblocks that were hit, blocks that were broken
    local num = 0
    
    for _, v in ipairs(self.liveReplacements) do
        if self:objVisible(v.x, v.y, 1, 1) then
            mainPerformanceTracker:track("live replacements drawn")
            num = num + 1
            drawOverBlock(v.x, v.y)
            
            local tile = self:getTile(v.x, v.y)
            tile:draw((v.x-1)*16, (v.y-1)*16)
        end
    end
    
    -- Blockbounces: If Mario bumps a block, it bounces. Have to draw these seperately because canvases.
    for _, v in ipairs(self.blockBounces) do -- Not checking for blockVisible because bumped blocks are probably always visible
        mainPerformanceTracker:track("blockbounces drawn")
        drawOverBlock(v.x, v.y)
        
        local tile = self:getTile(v.x, v.y)
        tile:draw((v.x-1)*16, (v.y-1-v.offset)*16)
    end

    love.graphics.setDepth(0)
    
    self.world:draw()
    for _, v in ipairs(self.portals) do
        v:draw()
    end
    --[[
    local cx, cy = self.marios[1].x+self.marios[1].width/2, self.marios[1].y+self.marios[1].height/2
    local mx, my = (love.mouse.getX()/TILESIZE)/SCALE+self.camera.x, love.mouse.getY()/TILESIZE/SCALE
    local dir = math.atan2(my-cy, mx-cx)

    local x, y, absX, absY, side = self:rayCast(cx, cy, dir)

    love.graphics.line(cx*TILESIZE, cy*TILESIZE, (absX)*TILESIZE, (absY)*TILESIZE)

    --]]
    self.camera:detach()
end

function Level:keypressed(key)
    if key == CONTROLS.jump and self.marios[1].onGround then
        self.marios[1]:jump()
    end
end

function Level:spawnEnemies(untilX)
    while self.spawnI <= #self.spawnList and untilX > self.spawnList[self.spawnI].x do -- Spawn next enemy
        toSpawn = self.spawnList[self.spawnI]
        Enemy:new(self.world, toSpawn.x, toSpawn.y, toSpawn.enemy.json, toSpawn.enemy.img, toSpawn.enemy.quad)

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
    
    -- Scroll right?
    if pXr > SCROLLINGCOMPLETE then
        self.camera.x = pX - SCROLLINGCOMPLETE
    elseif pXr > SCROLLINGSTART and pSpeedX > SCROLLRATE then
        self.camera.x = self.camera.x + SCROLLRATE*dt
    end
    -- Scroll left?
    if pXr < SCROLLINGLEFTCOMPLETE then
        self.camera.x = pX - SCROLLINGLEFTCOMPLETE
    elseif pXr < SCROLLINGLEFTSTART and pSpeedX < -SCROLLRATE then
        self.camera.x = self.camera.x - SCROLLRATE*dt
    end
    
    -- And clamp it to map boundaries
    self.camera.x = math.max(0, math.min(game.level.width - WIDTH - 1, self.camera.x))
end

function Level:inMap(x, y)
    return x > 0 and x <= self.width and y > 0 and y <= self.height
end

function Level:getTile(x, y)
    return self.tileMap.tiles[self.map[x][y]]
end

function Level:setMap(x, y, i)
    self.map[x][y] = i
    
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
    local tile = self:getTile(x, y)
    if tile.breakable or tile.coinBlock then
        local blockBounce = BlockBounce:new(x, y)
        
        table.insert(self.blockBounces, blockBounce)
        
        playSound(blockSound)

        if tile.coinBlock then
            self:setMap(x, y, 113)

            playSound(coinSound)
        end
    end
end

function Level:objVisible(x, y, w, h)
    return x+w > self.camera.x-OFFSCREENDRAW-OBJOFFSCREENDRAW and x < self.camera.x+WIDTH+OFFSCREENDRAW+OBJOFFSCREENDRAW and
        y+h > self.camera.y-OBJOFFSCREENDRAW and y < self.camera.y+HEIGHT+OBJOFFSCREENDRAW
end

function Level:rayCast(x, y, dir) -- Uses code from http://lodev.org/cgtutor/raycasting.html , thanks man
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