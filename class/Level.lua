Level = class("Level", fissix.World)

function Level:initialize(path)
    local levelCode = love.filesystem.read(path)
    self.data = sandbox.run(levelCode)

    fissix.World.initialize(self)
    self:loadMap(self.data)
    
    self.backgroundColor = self.data.backgroundColor or {156, 252, 240}
    self.backgroundColor[1] = self.backgroundColor[1]/255
    self.backgroundColor[2] = self.backgroundColor[2]/255
    self.backgroundColor[3] = self.backgroundColor[3]/255
    
    -- Camera stuff
    self.camera = Camera.new(CAMERAWIDTH/2, CAMERAHEIGHT/2, CAMERAWIDTH, CAMERAHEIGHT)
    
    self.camera.rot = 0
    self.spawnLine = 0
    self.spawnI = 1

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
    
    table.insert(self.marios, Smb3Mario:new(self, x, y, "raccoon"))
    
    self.camera.target = self.marios[1]

    self:spawnEnemies(self.camera.x+WIDTH+VAR("enemiesSpawnAhead")+2)
end

function Level:update(dt)
    updateGroup(self.blockBounces, dt)
    fissix.World.update(self, dt)
    self:updateCamera(dt)
    
    for _, obj in ipairs(self.objects) do
        if obj.postMovementUpdate then
            obj:postMovementUpdate(dt)
        end
    end

    local newSpawnLine = self.camera.x/self.tileSize+WIDTH+VAR("enemiesSpawnAhead")+2
    if newSpawnLine > self.spawnLine then
        self:spawnEnemies(newSpawnLine)
    end
end

function Level:draw()
    self.camera:attach()
    
    fissix.World.draw(self)
    
    for _, v in ipairs(self.marios) do
        v.crosshair:draw()
    end
    
    self.camera:detach()
end

function Level:cmdpressed(cmds)
    if cmds["jump"] then
        self.marios[1]:jump()
    end
    
    if cmds["closePortals"] then
        self.marios[1]:closePortals()
    end
    
    if cmds["run"] then
        self.marios[1]:spin()
        self.marios[1]:shoot()
    end
    
    if cmds["star"] then
        self.marios[1]:star()
    end
end

function Level:mousepressed(x, y, button)
    if button == 1 or button == 2 then
        local mario = self.marios[1]
        
        local portal = self:attemptPortal(mario.crosshair.target.tileX, mario.crosshair.target.tileY, mario.crosshair.target.blockSide, mario.crosshair.target.worldX, mario.crosshair.target.worldY, mario.portalColor[button], mario.portals[button])
        
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
    -- local mario = game.level.marios[1]
    -- local pX = mario.x
    -- local pXr = pX - self.camera.x
    
    -- -- Horizontal
    -- if pXr+mario.width > RIGHTSCROLLBORDER then
    --     self.camera.x = math.min(pX+mario.width-RIGHTSCROLLBORDER, self.camera.x + VAR("cameraScrollRate")*dt)
        
    -- elseif pXr < LEFTSCROLLBORDER then
    --     self.camera.x = math.max(pX-LEFTSCROLLBORDER, self.camera.x - VAR("cameraScrollRate")*dt)
    -- end
    
    -- -- Vertical
    -- local pY = mario.y
    -- local pYr = pY - self.camera.y
    
    -- if pYr+mario.height > DOWNSCROLLBORDER then
    --     self.camera.y = math.min(pY+mario.height-DOWNSCROLLBORDER, self.camera.y + VAR("cameraScrollRate")*dt)
    -- end
        
    -- -- Only scroll up in flight mode
    -- if mario.flying or self.camera.y < game.level.height*self.tileSize-CAMERAHEIGHT then
    --     if pYr < UPSCROLLBORDER then
    --         self.camera.y = math.max(pY-UPSCROLLBORDER, self.camera.y - VAR("cameraScrollRate")*dt)
    --     end
    -- end
    
    -- -- And clamp it to map boundaries
    -- self.camera.x = math.min(self.camera.x, game.level.width*self.tileSize - CAMERAWIDTH)
    -- self.camera.x = math.max(self.camera.x, 0)
    
    -- self.camera.y = math.min(self.camera.y, game.level.height*self.tileSize - CAMERAHEIGHT)
    -- self.camera.y = math.max(self.camera.y, 0)
    
    if self.camera.target then
        self.camera.x = self.marios[1].x+self.marios[1].width/2+0.001
        self.camera.y = self.marios[1].y+self.marios[1].height/2+0.001
    end
end

function Level:bumpBlock(x, y)
    local Tile = self:getTile(x, y)
    if Tile.breakable or Tile.coinBlock then
        local blockBounce = BlockBounce:new(x, y)
        
        table.insert(self.blockBounces, blockBounce)

        if Tile.coinBlock then
            self:setMap(x, y, 113)
        end
    end
end

function Level:objVisible(x, y, w, h)
    local lx, ty = self.camera:worldCoords(0, 0)
    local rx, by = self.camera:worldCoords(CAMERAWIDTH, CAMERAHEIGHT)
    
    return x+w > lx and x < rx and
        y+h > ty and y < by
end

function Level:resize(w, h)
    self.camera.w = w
    self.camera.h = h
end
