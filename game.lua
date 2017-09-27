game = {}

function game.load()
    gameState = "game"
    
    smbTileMap = TileMap:new("tilemaps/smb")
    testLevel = Level:new("levels/1-1.json", smbTileMap)

    mainCamera = Camera:new()
    mainCamera.x = 0
    mainCamera.y = -8

    myMario = Mario:new(testLevel.world, 5, 0)
end

function game.update(dt)
    testLevel:update(dt)
end

function game.draw()
    mainCamera:attach()
    testLevel:draw()
    mainCamera:detach()
end