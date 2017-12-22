Level = class("Level", fissix.World)

function Level:initialize(path, tileMap)
    self.data = require(path)
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
    
    table.insert(self.marios, Mario:new(self, x-6, y-12))

    self.portals = {}
    table.insert(self.portals, Portal:new(self, 16, 160, math.pi/4, {60, 188, 252}))
    table.insert(self.portals, Portal:new(self, 128, 208, 0, {232, 130, 30}))

    self.portals[1]:connectTo(self.portals[2])
    self.portals[2]:connectTo(self.portals[1])
    
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
    
    
    local xStart = math.max(1, self.camera.x)
    local xEnd = math.min(self.width, xStart+WIDTH-1)
    xEnd = math.min(self.width, xEnd)

    local yStart = 1
    local yEnd = HEIGHT
    
    self.drawList = {}
    
    for x = xStart, xEnd do
        for y = yStart, yEnd do
            for i = #self.map, 1, -1 do
                local Tile = self:getTile(x, y, i)
                if Tile and not Tile.invisible and Tile.type ~= "coinAnimation" then
                    Tile:draw((x-xStart)*self.tileMap.tileSize, (y-1)*self.tileMap.tileSize)
                end
            end
        end
    end

    fissix.World.draw(self)
    for _, v in ipairs(self.portals) do
        v:draw()
    end
    
    -- Line tracing debug
    --[[
    local cx, cy = self.marios[1].x+self.marios[1].width/2, self.marios[1].y+self.marios[1].height/2
    local mx, my = (love.mouse.getX())/SCALE+self.camera.x, love.mouse.getY()/SCALE
    local dir = math.atan2(my-cy, mx-cx)

    local x, y, absX, absY, side = self:rayCast(cx/self.tileSize, cy/self.tileSize, dir)

    absX, absY = self:mapToWorld(absX, absY)

    love.graphics.line(cx, cy, absX, absY)
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
    return x+w > self.camera.x/self.tileSize-OBJOFFSCREENDRAW and x < self.camera.x/self.tileSize+WIDTH+OBJOFFSCREENDRAW and
        y+h > self.camera.y/self.tileSize-OBJOFFSCREENDRAW and y < self.camera.y/self.tileSize+HEIGHT+OBJOFFSCREENDRAW
end

function Level:checkMapCollision(x, y)
    -- Portal hijacking
    for _, v in ipairs(self.portals) do
        if v.open then
            -- check if pixel is inside portal wallspace
            -- rotate x, y around portal origin
            local nx, ny = pointAroundPoint(x, y, v.x, v.y, -v.r)
            
            if  nx >= v.x and nx < v.x+v.size and
                ny >= v.y and ny < v.y+16 then
                return false
            end
        end
    end
    
    return fissix.World.checkMapCollision(self, x, y)
end