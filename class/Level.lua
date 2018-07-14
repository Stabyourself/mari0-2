local Camera = require "lib.Camera"
local Actor = require("class.Actor")
local Level = class("Level", Physics3.World)
local BlockBounce = require("class.BlockBounce")

function Level:initialize(path)
    local mapCode = love.filesystem.read(path)
    local data = sandbox.run(mapCode)

    self:loadLevel(data)

    self.timeLeft = 400

    self.camera.target = game.players[1].actor
end

function Level:loadLevel(data)
    self.data = data

    Physics3.World.initialize(self)
    Physics3.World.loadLevel(self, self.data)

    self.backgroundColor = self.data.backgroundColor or {156, 252, 240}
    self.backgroundColor[1] = self.backgroundColor[1]/255
    self.backgroundColor[2] = self.backgroundColor[2]/255
    self.backgroundColor[3] = self.backgroundColor[3]/255

    love.graphics.setBackgroundColor(self.backgroundColor)

    self.spawnLine = 0
    self.spawnI = 1

    self.activeCells = {} -- These cells will have :update called on them until they remove themselves from this list. Used for block bouncing.
    self.portalProjectiles = {} -- Portal projectiles, duh.

    self.spawnList = {}
    -- Parse entities
    for _, entity in ipairs(self.data.entities) do
        local actorTemplate = actorTemplates[entity.type]

        if actorTemplate and not VAR("noEnemies") then -- is enemy
            table.insert(self.spawnList, {
                actorTemplate = actorTemplate,
                x = entity.x,
                y = entity.y,
            })
        elseif entity.type == "spawn" then
            self.spawnX = entity.x
            self.spawnY = entity.y
        end
    end

    table.sort(self.spawnList, function(a, b) return a.x<b.x end)

    self.actors = {}

    local x, y = self:coordinateToWorld(self.spawnX-.5, self.spawnY)

    for i = 1, #game.players do
        local player = game.players[i]

        local mario = Actor:new(self, x, y, actorTemplates.smb3_raccoon)
        mario.player = player
        player.actor = mario

        -- apply settings like character palette and portal colors
        if player.palette then
            mario.palette = player.palette
        end

        table.insert(self.actors, mario)
    end

    self.camera = Camera.new(CAMERAWIDTH/2, CAMERAHEIGHT/2, CAMERAWIDTH, CAMERAHEIGHT)
    self.camera:lookAt(game.players[1].actor.x, game.players[1].actor.y)

    -- self:spawnActors(self.camera.x+WIDTH+VAR("enemiesSpawnAhead")+2)
end

function Level:update(dt)
    self.timeLeft = math.max(0, self.timeLeft-(60/42)*dt) -- that's 42.86% more second, per second!

    updateGroup(self.activeCells, dt)
    updateGroup(self.portalProjectiles, dt)

    -- print(#self.portalProjectiles)

    prof.push("World")
    Physics3.World.update(self, dt)
    prof.pop()

    self:updateCamera(dt)

    prof.push("Post Update")
    for _, obj in ipairs(self.objects) do
        if obj.postUpdate then
            obj:postUpdate(dt)
        end
    end
    prof.pop()

    if game.players[1].actor.y > self:getYEnd()*self.tileSize+.5 then
        game.players[1].actor.y = -1
    end

    -- local newSpawnLine = self.camera.x/self.tileSize+WIDTH+VAR("enemiesSpawnAhead")+2
    -- if newSpawnLine > self.spawnLine then
    --     self:spawnActors(newSpawnLine)
    -- end
end

function Level:draw()
    self.camera:attach()

    prof.push("World")
    Physics3.World.draw(self)
    prof.pop()

    self.camera:detach()
end

function Level:drawBehindObjects()
    for _, portalProjectile in ipairs(self.portalProjectiles) do
        portalProjectile:draw()
    end
end

function Level:cmdpressed(cmds)
    if cmds["jump"] then
        game.players[1].actor:event("jump")
    end

    if cmds["run"] then
        game.players[1].actor:event("action")
    end

    if cmds["closePortals"] then
        game.players[1].actor:event("closePortals")
    end

    if cmds["debug.star"] then -- debug
        game.players[1].actor:removeComponent("smb3.star")
        game.players[1].actor:addComponent("smb3.star")
    end
end

function Level:mousepressed(x, y, button)
    for _, obj in ipairs(self.objects) do
        obj:event("click", 0, button)
    end
end

function Level:spawnActors(untilX)
    while self.spawnI <= #self.spawnList and untilX > self.spawnList[self.spawnI].x do -- Spawn next enemy
        toSpawn = self.spawnList[self.spawnI]
        local x, y = self:coordinateToWorld(toSpawn.x-.5, toSpawn.y)
        local actor = Actor:new(self, x, y, toSpawn.actorTemplate)

        table.insert(self.actors, actor)

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
        self.camera.x = math.max(self.camera.x, (self:getXStart()-1)*self.tileSize+CAMERAWIDTH/2)

        self.camera.y = math.min(self.camera.y, self:getYEnd()*self.tileSize-CAMERAHEIGHT/2)
        self.camera.y = math.max(self.camera.y, (self:getYStart()-1)*self.tileSize+CAMERAHEIGHT/2)
    end
end

function Level:bumpBlock(cell, actor)
    local tile = cell.tile

    if tile.breakable or tile.props.holdsItems then
        -- Make it bounce
        cell:bounce()
        table.insert(self.activeCells, cell)

        if tile.props.turnsInto then
            local turnIntoTile = tile.tileMap.tiles[tile.props.turnsInto]

            cell.tile = turnIntoTile
        end

        -- Check what's inside
        local item = tile.props.defaultItem
        if item == "coin" then
            self:collectCoin(actor)
        end
    end
end

function Level:collectCoin(actor, layer, x, y)
    if layer then
        layer.map[x][y].tile = nil
    end
    actor.player.coins = actor.player.coins + 1
end

function Level:objVisible(x, y, w, h)
    local lx, ty = self.camera:worldCoords(0, 0)
    local rx, by = self.camera:worldCoords(CAMERAWIDTH, CAMERAHEIGHT)

    return x+w > lx and x < rx and
        y+h > ty and y < by
end

function Level:resize(w, h)
    self.camera.w = w
    self.camera.h = CAMERAHEIGHT
end

return Level
