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
    
    -- Parse entities
    for _, v in ipairs(self.json.entities) do
        local enemy = self.enemyList[v.type]

        if enemy then -- is enemy
            Enemy:new(self.world, v.x, v.y, enemy.json, enemy.img, enemy.quad)
        elseif v.type == "spawn" then
            self.spawnX = v.x
            self.spawnY = v.y
        end
    end

    self.marios = {}
    table.insert(self.marios, Mario:new(self.world, self.spawnX-6/16, self.spawnY-12/16))
end

function Level:update(dt, camera)
    updateGroup(self.world.activeObjects, dt)
    updateGroup(self.blockBounces, dt)
    self.world:update(dt)
end

function Level:draw(camera)
    for _, v in ipairs(self.drawList) do
        local offset = 0
        local bounce = self.bounceLookup[v.x][v.y]
        
        if bounce then
            offset = bounce.offset
        end
            
        v.tile:draw((v.x-1)*16, (v.y-1-offset)*16)
    end
    
    self.world:draw()
end

function Level:keypressed(key)
    if key == CONTROLS.jump and self.marios[1].onGround then
        self.marios[1]:jump()
    end
end

function Level:checkDrawList(camera)
    if math.floor(camera.x)+1-EXTRADRAWING ~= self.drawListX then
        self:generateDrawList(camera)
    end
end

function Level:generateDrawList(camera)
    local xStart = math.floor(camera.x)+1-EXTRADRAWING
    local yStart = math.floor(camera.y)+1-EXTRADRAWING
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
