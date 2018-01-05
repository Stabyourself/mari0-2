Level = class("Level", fissix.World)

function Level:initialize(path, tileMap)
    local levelCode = love.filesystem.read(path)
    self.data = sandbox.run(levelCode)
    self.tileMap = tileMap

    fissix.World.initialize(self, tileMap)
    self:loadMap(self.data.map)
    
    self.backgroundColor = self.data.backgroundColor or {156, 252, 240}

    self.enemyList = loadEnemies()
    
    self.blockBounces = {}
    
    self.spawnList = {}
    -- Parse entities
    for _, v in ipairs(self.data.entities) do
        local enemy = self.enemyList[v.type]

        if enemy and not VAR("noEnemies") then -- is enemy
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

    local x, y = self:mapToWorld(self.spawnX-.5, self.spawnY)
    
    table.insert(self.marios, Smb3Mario:new(self, x, y, "small"))
    
    -- Camera stuff
    self.camera = Camera:new()
    self.camera.y = self.height*self.tileSize - CAMERAHEIGHT
    print(self.camera.y)
    self.spawnLine = 0
    self.spawnI = 1

    self:spawnEnemies(self.camera.x+WIDTH+VAR("enemiesSpawnAhead")+2)
end

function Level:update(dt)
    updateGroup(self.blockBounces, dt)
    fissix.World.update(self, dt)
    self:updateCamera(dt)

    local newSpawnLine = self.camera.x/self.tileSize+WIDTH+VAR("enemiesSpawnAhead")+2
    if newSpawnLine > self.spawnLine then
        self:spawnEnemies(newSpawnLine)
    end
end

function Level:draw()
    self.camera:attach()
    
    love.graphics.setColor(255, 255, 255)
    
    for _, v in ipairs(self.marios) do
        love.graphics.line(v.x+v.width/2, v.y+v.height/2+2, v.crosshairX, v.crosshairY)
    end
    
    fissix.World.draw(self)
    
    self.camera:detach()
end

function Level:keypressed(key)
    if key == VAR("controls").jump then
        self.marios[1]:jump()
    end
    
    if key == VAR("controls").boost then
        self.marios[1].speedX = 1000
    end
    
    if key == VAR("controls").closePortals then
        self.marios[1]:closePortals()
    end
    
    if key == VAR("controls").run then
        self.marios[1]:spin()
        self.marios[1]:shoot()
    end
    
    if key == VAR("controls").star then
        self.marios[1]:star()
    end
end

function Level:mousepressed(x, y, button)
    local mario = self.marios[1]
    
    local portal = self:attemptPortal(mario.crosshairTileX, mario.crosshairTileY, mario.crosshairSide, mario.crosshairX, mario.crosshairY, mario.portalColor[button])
    
    if portal then
        if mario.portals[button] then
            mario.portals[button].deleteMe = true
        end
        
        mario.portals[button] = portal
                
        if mario.portals[1] and mario.portals[2] then
            mario.portals[1]:connectTo(mario.portals[2])
            mario.portals[2]:connectTo(mario.portals[1])

            mario.portals[button].timer = mario.portals[button].connectsTo.timer
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
    local mario = game.level.marios[1]
    local pX = mario.x
    local pXr = pX - self.camera.x
    
    -- Horizontal
    if pXr+mario.width > RIGHTSCROLLBORDER then
        self.camera.x = math.min(pX+mario.width-RIGHTSCROLLBORDER, self.camera.x + VAR("cameraScrollRate")*dt)
        
    elseif pXr < LEFTSCROLLBORDER then
        self.camera.x = math.max(pX-LEFTSCROLLBORDER, self.camera.x - VAR("cameraScrollRate")*dt)
    end
    
    -- Vertical
    local pY = mario.y
    local pYr = pY - self.camera.y
    
    if pYr+mario.height > DOWNSCROLLBORDER then
        self.camera.y = math.min(pY+mario.height-DOWNSCROLLBORDER, self.camera.y + VAR("cameraScrollRate")*dt)
    end
        
    -- Only scroll up in flight mode
    if mario.flying or self.camera.y < game.level.height*self.tileSize-CAMERAHEIGHT then
        if pYr < UPSCROLLBORDER then
            self.camera.y = math.max(pY-UPSCROLLBORDER, self.camera.y - VAR("cameraScrollRate")*dt)
        end
    end
    
    -- And clamp it to map boundaries
    self.camera.x = math.min(self.camera.x, game.level.width*self.tileSize - CAMERAWIDTH)
    self.camera.x = math.max(self.camera.x, 0)
    
    self.camera.y = math.min(self.camera.y, game.level.height*self.tileSize - CAMERAHEIGHT)
    self.camera.y = math.max(self.camera.y, 0)
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
    return x+w > self.camera.x and x < self.camera.x+CAMERAWIDTH and
        y+h > self.camera.y and y < self.camera.y+CAMERAHEIGHT
end
