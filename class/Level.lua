Level = class("Level")

function Level:initialize(path, tileMap)
    self.json = JSON:decode(love.filesystem.read(path))
    self.tileMap = tileMap
    
    self.map = self.json.map
    self.background = self.json.background
    self.width = #self.map
    self.height = #self.map[1]

    self.enemyList = loadEnemies()
    
    self.world = World:new()

    self.blocks = {}
    for x = 1, self.width do
        self.blocks[x] = {}

        for y = 1, self.height do
            if self.tileMap.tiles[self.map[x][y]] then
                if self.tileMap.tiles[self.map[x][y]].collision then
                    self.blocks[x][y] = Block:new(self.world, x, y)
                end
            end
        end
    end
    
    self.blockBounces = {}
    self.bounceLookup = {}
    for x = 1, self.width do
        self.bounceLookup[x] = {}
    end
    
    self.spawnList = {}
    -- Parse entities
    for _, v in ipairs(self.json.entities) do
        local enemy = self.enemyList[v.type]

        if enemy then -- is enemy
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
    

    self.camera = Camera:new()
    self.spawnLine = 0
    self.spawnI = 1

    self:generateDrawList()
end

function Level:update(dt)
    updateGroup(self.world.activeObjects, dt)
    updateGroup(self.blockBounces, dt)
    self.world:update(dt)
    self:updateCamera(dt)
    
    local newSpawnLine = self.camera.x+WIDTH+ENEMIESPSAWNAHEAD+2
    if newSpawnLine > self.spawnLine then
        self:spawnEnemies(newSpawnLine)
    end
    
    self:checkDrawList()
end

function Level:draw()
    self.camera:attach()

    for _, v in ipairs(self.drawList) do
        local offset = 0
        local bounce = self.bounceLookup[v.x][v.y]
        
        if bounce then
            offset = bounce.offset
        end
            
        v.tile:draw((v.x-1)*16, (v.y-1-offset)*16)
    end

    love.graphics.setDepth(0)
    
    self.world:draw()

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
    
    -- RIGHT
    if pXr > SCROLLINGCOMPLETE then
        self.camera.x = pX - SCROLLINGCOMPLETE
    elseif pXr > SCROLLINGSTART and pSpeedX > SCROLLRATE then
        self.camera.x = self.camera.x + SCROLLRATE*dt
    end
    -- LEFT
    if pXr < SCROLLINGLEFTCOMPLETE then
        self.camera.x = pX - SCROLLINGLEFTCOMPLETE
    elseif pXr < SCROLLINGLEFTSTART and pSpeedX < -SCROLLRATE then
        self.camera.x = self.camera.x - SCROLLRATE*dt
    end
    
    -- And clamp it to map boundaries
    self.camera.x = math.max(0, math.min(game.level.width - WIDTH - 1, self.camera.x))
end

function Level:checkDrawList()
    if math.floor(self.camera.x)+1-EXTRADRAWING ~= self.drawListX then
        self:generateDrawList(self.camera)
    end
end

function Level:generateDrawList()
    local xStart = math.floor(self.camera.x)+1-EXTRADRAWING
    local yStart = math.floor(self.camera.y)+1-EXTRADRAWING
    local xEnd = xStart + WIDTH+EXTRADRAWING*2
    local yEnd = yStart + HEIGHT+EXTRADRAWING*2
    
    local toDraw = {}
    
    self.drawList = {}
    self.drawListX = xStart
    
    for x = xStart, xEnd do
        for y = yStart, yEnd do
            if self:inMap(x, y) then
                local tile = self.tileMap.tiles[self.map[x][y]]
                
                if tile and not tile.invisible then
                    table.insert(self.drawList, {
                        x = x,
                        y = y,
                        tile = tile
                    })
                end
                
                tile = self.tileMap.tiles[self.background[x][y]]
                
                if tile and not tile.invisible then
                    table.insert(self.drawList, {
                        x = x,
                        y = y,
                        tile = tile
                    })
                end
            end
        end
    end
    
    table.sort(self.drawList, function(a, b) return a.tile.depth>b.tile.depth end)
end

function Level:inMap(x, y)
    return x > 0 and x <= self.width and y > 0 and y <= self.height
end

function Level:getTile(x, y)
    return self.tileMap.tiles[self.map[x][y]]
end

function Level:bumpBlock(x, y)
    local tile = self:getTile(x, y)
    if tile.breakable or tile.coinBlock then
        local blockBounce = BlockBounce:new(x, y)
        
        table.insert(self.blockBounces, blockBounce)
        self.bounceLookup[x][y] = blockBounce

        if tile.coinBlock then
            self.map[x][y] = 113
            self:generateDrawList(mainCamera)

            playSound(coinSound)
        end
    end
end
