game = {}

function game.load()
    if not is3DS then
        love.window.setMode(400, 480)
    end
    
    gameState = "game"
    
    smbTileMap = TileMap:new("tilemaps/smb")
    myLevel = Level:new("levels/1-1.json", smbTileMap)
    
    love.graphics.setBackgroundColor(myLevel.backgroundColor or {92, 148, 252})

    mainCamera = Camera:new()
    mainCamera.x = 0
    mainCamera.y = 0
    
    myLevel:generateDrawList(mainCamera)

    marios = {}
    table.insert(marios, Mario:new(myLevel.world, 5, 0))

    playMusic(overworldMusic)

    skipUpdate()
end

function game.update(dt)
    updateGroup(marios, dt)
    
    myLevel:update(dt)
    
    mainCamera.x = marios[1].x - 5
    
    myLevel:checkDrawList(mainCamera)
end

function game.draw()
    mainCamera:attach()
    myLevel:draw(mainCamera)
    
    for _, v in ipairs(marios) do
        v:draw()
    end
    
    mainCamera:detach()
end

function game.keypressed(key)
    if key == CONTROLS.jump and marios[1].onGround then
        marios[1]:jump()
    end
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