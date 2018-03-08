Level = class("Level", Physics3.World)

function Level:initialize(path)
    local data = JSON:decode(love.filesystem.read(path))
    
    self:loadMap(data)
    
    self.camera.target = self.marios[1]
end

function Level:loadMap(data)
    self.data = data
    
    Physics3.World.initialize(self)
    Physics3.World.loadMap(self, self.data)
    
    self.backgroundColor = self.data.backgroundColor or {156, 252, 240}
    self.backgroundColor[1] = self.backgroundColor[1]/255
    self.backgroundColor[2] = self.backgroundColor[2]/255
    self.backgroundColor[3] = self.backgroundColor[3]/255
    
    -- Camera stuff
    self.camera = Camera.new(CAMERAWIDTH/2, CAMERAHEIGHT/2, CAMERAWIDTH, CAMERAHEIGHT)
    
    self.camera.rot = 0
    self.controlsEnabled = true
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
                y = v.y,
            })
        elseif v.type == "spawn" then
            self.spawnX = v.x
            self.spawnY = v.y
        end
    end

    table.sort(self.spawnList, function(a, b) return a.x<b.x end)

    self.actors = {} -- todo: this is meh
    self.marios = {}

    local x, y = self:mapToWorld(self.spawnX-.5, self.spawnY)
    
    local mario1 = Actor:new(self, x, y, actorTemplates.mario)
    table.insert(self.marios, mario1)
    table.insert(self.actors, mario1)
    
    table.insert(self.actors, Actor:new(self, 100, 100, actorTemplates.goomba))
    
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
    
    if cmds["closePortals"] then
        self.marios[1]:event("closePortals")
    end
    
    if cmds["run"] then
        self.marios[1]:event("action")
    end
    
    if cmds["star"] then
        self.marios[1]:event("star")
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
    if self.camera.target then
        local target = self.camera.target
        local pX = target.x + target.width/2
        local pXr = pX - self.camera.x
        
        -- Horizontal
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
        if target.flying or self.camera.y < self.height*self.tileSize-CAMERAHEIGHT then
            if pYr < UPSCROLLBORDER then
                self.camera.y = self.camera.y - VAR("cameraScrollRate")*dt
            
                if pY - self.camera.y > UPSCROLLBORDER then
                    self.camera.y = pY - UPSCROLLBORDER
                end
            end
        end
        
        -- -- And clamp it to map boundaries
        self.camera.x = math.min(self.camera.x, self.width*self.tileSize-CAMERAWIDTH/2)
        self.camera.x = math.max(self.camera.x, CAMERAWIDTH/2)
        
        self.camera.y = math.min(self.camera.y, self.height*self.tileSize-CAMERAHEIGHT/2)
        self.camera.y = math.max(self.camera.y, CAMERAHEIGHT/2)
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
