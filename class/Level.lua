Level = class("Level", Physics3.World)

function Level:initialize(path)
    local data = JSON:decode(love.filesystem.read(path))
    
    self:loadLevel(data)
    
    self.camera.target = self.marios[1]
end

function Level:loadLevel(data)
    self.data = data
    
    Physics3.World.initialize(self)
    Physics3.World.loadLevel(self, self.data)
    
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
    for _, entity in ipairs(self.data.entities) do
        local enemy = self.enemyList[entity.type]

        if enemy and not VAR("noEnemies") then -- is enemy
            table.insert(self.spawnList, {
                enemy = enemy,
                x = entity.x,
                y = entity.y,
            })
        elseif entity.type == "spawn" then
            self.spawnX = entity.x
            self.spawnY = entity.y
        end
    end

    table.sort(self.spawnList, function(a, b) return a.x<b.x end)

    self.actors = {} -- todo: this is meh
    self.marios = {}

    local x, y = self:coordinateToWorld(self.spawnX-.5, self.spawnY)
    
    local mario = Actor(self, x, y, actorTemplates.smb3_raccoon)

    table.insert(self.marios, mario)
    table.insert(self.actors, mario)
    
    table.insert(self.actors, Actor(self, 100, 100, actorTemplates.goomba))
    
    self:spawnEnemies(self.camera.x+WIDTH+VAR("enemiesSpawnAhead")+2)
end

function Level:update(dt)
    updateGroup(self.blockBounces, dt)
    
    prof.push("World")
    Physics3.World.update(self, dt)
    prof.pop()

    self:updateCamera(dt)
    
    prof.push("Post Movement")
    for _, obj in ipairs(self.objects) do
        if obj.postUpdate then
            obj:postUpdate(dt)
        end
    end
    prof.pop()

    local newSpawnLine = self.camera.x/self.tileSize+WIDTH+VAR("enemiesSpawnAhead")+2
    if newSpawnLine > self.spawnLine then
        self:spawnEnemies(newSpawnLine)
    end
end

function Level:draw()
    self.camera:attach()
    
    prof.push("World")
    Physics3.World.draw(self)
    prof.pop()
    
    self.camera:detach()
end

function Level:cmdpressed(cmds)
    if cmds["jump"] then
        self.marios[1]:event("jump")
    end
    
    if cmds["run"] then
        self.marios[1]:event("action")
    end
    
    if cmds["closePortals"] then
        self.marios[1]:event("closePortals")
    end
    
    if cmds["debug.star"] then -- debug
        self.marios[1]:removeComponent(components["smb3.star"])
        self.marios[1]:addComponent(components["smb3.star"])
    end
end

function Level:mousepressed(x, y, button)
    for _, obj in ipairs(self.objects) do
        obj:event("click", 0, button)
    end
end

function Level:spawnEnemies(untilX)
    while self.spawnI <= #self.spawnList and untilX > self.spawnList[self.spawnI].x do -- Spawn next enemy
        toSpawn = self.spawnList[self.spawnI]
        local x, y = self:coordinateToWorld(toSpawn.x-.5, toSpawn.y)
        Enemy:new(self, x, y, toSpawn.enemy.json, toSpawn.enemy.img, toSpawn.enemy.quad)

        self.spawnI = self.spawnI + 1

        -- Update untilX so enemies spawn in groups
        untilX = untilX + 2
    end

    self.spawnLine = untilX
end

function Level:updateCamera(dt)
    if self.camera.target then
        local target = self.camera.target
        
        -- Horizontal
        local pX = target.x + target.width/2
        local pXr = pX - self.camera.x
        
        if pXr > RIGHTSCROLLBORDER then
            self.camera.x = self.camera.x + VAR("cameraScrollRate")*dt
            
            if pX - self.camera.x < RIGHTSCROLLBORDER then
                self.camera.x = pX - RIGHTSCROLLBORDER
            end
            
        elseif pXr < LEFTSCROLLBORDER then
            self.camera.x = self.camera.x - VAR("cameraScrollRate")*dt
            
            if pX - self.camera.x > LEFTSCROLLBORDER then
                self.camera.x = pX - LEFTSCROLLBORDER
            end
        end
        
        -- Vertical
        local pY = target.y + target.height/2
        local pYr = pY - self.camera.y
        
        if pYr > DOWNSCROLLBORDER then
            self.camera.y = self.camera.y + VAR("cameraScrollRate")*dt
            
            if pY - self.camera.y < DOWNSCROLLBORDER then
                self.camera.y = pY - DOWNSCROLLBORDER
            end
        end
            
        -- Only scroll up in flight mode
        if target.flying or self.camera.y < self:getYEnd()*self.tileSize-CAMERAHEIGHT then -- ?
            if pYr < UPSCROLLBORDER then
                self.camera.y = self.camera.y - VAR("cameraScrollRate")*dt
            
                if pY - self.camera.y > UPSCROLLBORDER then
                    self.camera.y = pY - UPSCROLLBORDER
                end
            end
        end
        
        -- -- And clamp it to level boundaries
        self.camera.x = math.min(self.camera.x, self:getXEnd()*self.tileSize-CAMERAWIDTH/2)
        self.camera.x = math.max(self.camera.x, CAMERAWIDTH/2)
        
        self.camera.y = math.min(self.camera.y, self:getYEnd()*self.tileSize-CAMERAHEIGHT/2)
        self.camera.y = math.max(self.camera.y, CAMERAHEIGHT/2)
    end
end

function Level:bumpBlock(x, y)
    local Tile = self:getTile(x, y)
    if Tile.breakable or Tile.coinBlock then
        local blockBounce = BlockBounce:new(x, y)
        
        table.insert(self.blockBounces, blockBounce)

        if Tile.coinBlock then
            self:setCoordinate(x, y, 113)
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
