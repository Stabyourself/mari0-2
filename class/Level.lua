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
    
    -- Camera stuff
    self.camera = Camera:new()
    self.spawnLine = 0
    self.spawnI = 1

    -- Level canvases
    print("Prerendering level...")
    self.levelCanvases = {}
    for x = 0, math.floor(self.width/LEVELCANVASWIDTH) do
        table.insert(self.levelCanvases, LevelCanvas:new(self, x*LEVELCANVASWIDTH+1))
    end

    self:spawnEnemies(self.camera.x+WIDTH+ENEMIESPSAWNAHEAD+2)
end

function Level:update(dt)
    -- Clean up enemies
	local delete = {}
    
    for i, v in ipairs(self.world.activeObjects) do
        if v.autoRemove and 
            (v.x+v.width < self.camera.x-1 or
            v.y > HEIGHT+1) then
			table.insert(delete, i)
        end
    end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for _, v in ipairs(delete) do
		table.remove(self.world.activeObjects, v)
	end
    
    updateGroup(self.world.activeObjects, dt)
    updateGroup(self.blockBounces, dt)
    self.world:update(dt)
    self:updateCamera(dt)

    local newSpawnLine = self.camera.x+WIDTH+ENEMIESPSAWNAHEAD+2
    if newSpawnLine > self.spawnLine then
        self:spawnEnemies(newSpawnLine)
    end

    if self.marios[1].y > HEIGHT then
        self.marios[1].y = 0
    end
end

function Level:draw()
    self.camera:attach()
    
    -- MAIN LEVELCANVAS
    local mainCanvasI = math.floor((self.camera.x)/LEVELCANVASWIDTH)+1
    mainCanvasI = math.max(1, mainCanvasI)
    
    love.graphics.draw(self.levelCanvases[mainCanvasI].canvas, ((mainCanvasI-1)*LEVELCANVASWIDTH-OFFSCREENDRAW)*TILESIZE, 0)
    
    -- LEFT ADDITION (for 3D)
    if math.fmod(self.camera.x, LEVELCANVASWIDTH) < OFFSCREENDRAW and mainCanvasI > 1 then
        love.graphics.draw(self.levelCanvases[mainCanvasI-1].canvas, ((mainCanvasI-2)*LEVELCANVASWIDTH-OFFSCREENDRAW)*TILESIZE, 0)
    end
    
    -- RIGHT ADDITION (for transition to next levelCanvas and 3D)
    if math.fmod(self.camera.x, LEVELCANVASWIDTH) > LEVELCANVASWIDTH-WIDTH-OFFSCREENDRAW and mainCanvasI < #self.levelCanvases then
        love.graphics.draw(self.levelCanvases[mainCanvasI+1].canvas, ((mainCanvasI)*LEVELCANVASWIDTH-OFFSCREENDRAW)*TILESIZE, 0)
    end
    
    -- Live replacements: Coinblocks that were hit, blocks that were broken
    local num = 0
    
    for _, v in ipairs(self.liveReplacements) do
        if self:blockVisible(v.x, v.y) then
            num = num + 1
            drawOverBlock(v.x, v.y)
            
            local tile = self:getTile(v.x, v.y)
            tile:draw((v.x-1)*16, (v.y-1)*16)
        end
    end
    
    -- Blockbounces: If Mario bumps a block, it bounces. Have to draw these seperately because canvases.
    for _, v in ipairs(self.blockBounces) do -- Not checking for blockVisible because bumped blocks are probably always visible
        drawOverBlock(v.x, v.y)
        
        local tile = self:getTile(v.x, v.y)
        tile:draw((v.x-1)*16, (v.y-1-v.offset)*16)
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

function Level:blockVisible(x, y)
    return x > self.camera.x - OFFSCREENDRAW and x < self.camera.x+WIDTH+OFFSCREENDRAW
end
