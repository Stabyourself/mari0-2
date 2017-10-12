Level = class("Level", fissix.World)

function Level:initialize(path, tileMap)
    self.json = JSON:decode(love.filesystem.read(path))
    self.tileMap = tileMap

    fissix.World.initialize(self, tileMap)
    self:loadMap(self.json.maps)
    
    self.background = self.json.background
    self.backgroundColor = self.json.backgroundColor or {92, 148, 252}

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

    local x, y = self:mapToWorld(self.spawnX, self.spawnY)
    
    table.insert(self.marios, Mario:new(self, x-6, y-12))

    self.portals = {}
    --[[
    table.insert(self.portals, Portal:new(self, 4, 7, math.pi/4, {60, 188, 252}))
    table.insert(self.portals, Portal:new(self, 8, 12, 0, {232, 130, 30}))

    self.portals[1].connectsTo = self.portals[2]
    self.portals[2].connectsTo = self.portals[1]
    --]]
    
    -- Camera stuff
    self.camera = Camera:new()
    self.spawnLine = 0
    self.spawnI = 1

    -- Level canvases
    print("Prerendering level...")
    self.worldCanvases = {}
    for x = 0, math.floor(self.width/LEVELCANVASWIDTH) do
        table.insert(self.worldCanvases, WorldCanvas:new(self, x*LEVELCANVASWIDTH+1))
    end

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
    
    -- MAIN WORLDCANVAS
    local mainCanvasI = math.floor((self.camera.x/self.tileSize)/LEVELCANVASWIDTH)+1
    mainCanvasI = math.max(1, mainCanvasI)
    
    love.graphics.draw(self.worldCanvases[mainCanvasI].canvas, ((mainCanvasI-1)*LEVELCANVASWIDTH-OFFSCREENDRAW)*TILESIZE, 0)
    mainPerformanceTracker:track("worldCanvases drawn")
    
    -- LEFT ADDITION (for 3D)
    if math.fmod((self.camera.x/self.tileSize), LEVELCANVASWIDTH) < OFFSCREENDRAW and mainCanvasI > 1 then
        mainPerformanceTracker:track("worldCanvases drawn")
        love.graphics.draw(self.worldCanvases[mainCanvasI-1].canvas, ((mainCanvasI-2)*LEVELCANVASWIDTH-OFFSCREENDRAW)*TILESIZE, 0)
    end
    
    -- RIGHT ADDITION (for transition to next WorldCanvas and 3D)
    if math.fmod((self.camera.x/self.tileSize), LEVELCANVASWIDTH) > LEVELCANVASWIDTH-WIDTH-OFFSCREENDRAW and mainCanvasI < #self.worldCanvases then
        mainPerformanceTracker:track("worldCanvases drawn")
        love.graphics.draw(self.worldCanvases[mainCanvasI+1].canvas, ((mainCanvasI)*LEVELCANVASWIDTH-OFFSCREENDRAW)*TILESIZE, 0)
    end
    
    -- Live replacements: Coinblocks that were hit, blocks that were broken
    local num = 0
    
    for _, v in ipairs(self.liveReplacements) do
        if self:objVisible(v.x, v.y, 1, 1) then
            mainPerformanceTracker:track("live replacements drawn")
            num = num + 1
            drawOverBlock(v.x, v.y)
            
            local Tile = self:getTile(v.x, v.y)
            Tile:draw((v.x-1)*self.tileSize, (v.y-1)*self.tileSize)
        end
    end
    
    -- Blockbounces: If Mario bumps a block, it bounces. Have to draw these seperately because canvases.
    for _, v in ipairs(self.blockBounces) do -- Not checking for blockVisible because bumped blocks are probably always visible
        mainPerformanceTracker:track("blockbounces drawn")
        drawOverBlock(v.x, v.y)
        
        local Tile = self:getTile(v.x, v.y)
        Tile:draw((v.x-1)*self.tileSize, (v.y-1-v.offset)*self.tileSize)
    end

    love.graphics.setDepth(0)
    
    fissix.World.draw(self)
    for _, v in ipairs(self.portals) do
        v:draw()
    end
    -- Line tracing debug
    local cx, cy = self.marios[1].x+self.marios[1].width/2, self.marios[1].y+self.marios[1].height/2
    local mx, my = (love.mouse.getX())/SCALE+self.camera.x, love.mouse.getY()/SCALE
    local dir = math.atan2(my-cy, mx-cx)

    local x, y, absX, absY, side = self:rayCast(cx/self.tileSize, cy/self.tileSize, dir)

    absX, absY = self:mapToWorld(absX, absY)

    love.graphics.line(cx, cy, absX, absY)

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
    
    -- And clamp it to map boundaries
    self.camera.x = math.clamp(self.camera.x, 0, (game.level.width - WIDTH - 1)*self.tileSize)
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
    return x+w > self.camera.x/self.tileSize-OFFSCREENDRAW-OBJOFFSCREENDRAW and x < self.camera.x/self.tileSize+WIDTH+OFFSCREENDRAW+OBJOFFSCREENDRAW and
        y+h > self.camera.y/self.tileSize-OBJOFFSCREENDRAW and y < self.camera.y/self.tileSize+HEIGHT+OBJOFFSCREENDRAW
end