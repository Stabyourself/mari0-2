game = {}

function game.load()
    gameState = "game"
    
    smbTileMap = TileMap:new("tilemaps/smb")
    myLevel = Level:new("levels/1-1.json", smbTileMap)
    
    love.graphics.setBackgroundColor(myLevel.backgroundColor or {92, 148, 252})

    mainCamera = Camera:new()
    mainCamera.x = 0
    mainCamera.y = 0.5

    marios = {}
    table.insert(marios, Mario:new(myLevel.world, 5, 0))
end

function game.update(dt)
    myLevel:update(dt)
    
    updateGroup(marios, dt)
    mainCamera.x = marios[1].x - 5
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
    if key == CONTROLS[1].jump and marios[1].onGround then
        marios[1]:jump()
    end
end