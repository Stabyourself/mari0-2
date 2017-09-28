game = {}

function game.load()
    if not is3DS then
        love.window.setMode(416, 480)
    end
    
    gameState = "game"
    
    smbTileMap = TileMap:new("tilemaps/smb")
    game.level = Level:new("levels/1-1.json", smbTileMap)
    
    love.graphics.setBackgroundColor(game.level.backgroundColor or {92, 148, 252})

    mainCamera = Camera:new()
    mainCamera.x = 0
    mainCamera.y = 0
    
    game.level:generateDrawList(mainCamera)
    
    game.timeLeft = 400

    marios = {}
    table.insert(marios, Mario:new(game.level.world, game.level.spawnX-6/TILESIZE, game.level.spawnY-12/TILESIZE))

    playMusic(overworldMusic)

    skipUpdate()
end

function game.update(dt)
    game.timeLeft = math.max(0, game.timeLeft-2.5*dt)
    
    updateGroup(marios, dt)
    
    game.level:update(dt)
    
    game.updateCamera(mainCamera, dt)
    
    game.level:checkDrawList(mainCamera)
end

function game.draw()
    mainCamera:attach()
    game.level:draw(mainCamera)
    
    for _, v in ipairs(marios) do
        v:draw()
    end
    
    mainCamera:detach()
    
    -- UI
    -- score
    marioPrint("mario", 24, 16, "left", -10*DEPTHMUL)
    marioPrint("012345", 24, 24, "left", -10*DEPTHMUL)
    
    -- coins (abused as FPS for now)
    marioPrint("fps*" .. love.timer.getFPS(), round((SCREENWIDTH-80)/3)+40, 24, "center", -10*DEPTHMUL)
    
    -- level
    marioPrint("world", round((SCREENWIDTH-80)/3*2)+40, 16, "center", -10*DEPTHMUL)
    marioPrint(" 1-1 ", round((SCREENWIDTH-80)/3*2)+40, 24, "center", -10*DEPTHMUL)
    
    -- time
    marioPrint("time", SCREENWIDTH-24, 16, "right", -10*DEPTHMUL)
    marioPrint(padZeroes(math.ceil(game.timeLeft), 3), SCREENWIDTH-24, 24, "right", -10*DEPTHMUL)
end

function game.keypressed(key)
    if key == CONTROLS.jump and marios[1].onGround then
        marios[1]:jump()
    end
end

function game.updateCamera(camera, dt)
    local pX = marios[1].x
    local pXr = pX - camera.x
    local pSpeedX = marios[1].speedX
    
    -- RIGHT
    if pXr > SCROLLINGCOMPLETE then
        camera.x = pX - SCROLLINGCOMPLETE
    elseif pXr > SCROLLINGSTART and pSpeedX > SCROLLRATE then
        camera.x = camera.x + SCROLLRATE*dt
    end
    -- LEFT
    if pXr < SCROLLINGLEFTCOMPLETE then
        camera.x = pX - SCROLLINGLEFTCOMPLETE
    elseif pXr < SCROLLINGLEFTSTART and pSpeedX < -SCROLLRATE then
        camera.x = camera.x - SCROLLRATE*dt
    end
    
    -- And clamp it to map boundaries
    camera.x = math.max(0, math.min(game.level.width - WIDTH - 1, camera.x))
end

function worldDraw(img, quad, x, y, r, sx, sy, ox, oy)
    if type(quad) == "number" then
        img, x, y, r, sx, sy, ox, oy = img, quad, x, y, r, sx, sy, ox
        quad = false
    end

    x = round(x*TILESIZE)
    y = round(y*TILESIZE)

    if not quad then
        love.graphics.draw(img, x, y, r, sx, sy, ox, oy)
    else
        love.graphics.draw(img, quad, x, y, r, sx, sy, ox, oy)
    end
end

function round(i)
    if i > 0 then
        return math.floor(i+.5)
    else
        return math.ceil(i-.5)
    end
end