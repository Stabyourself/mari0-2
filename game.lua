game = {}

function game.load()
    gameState = "game"
    
    smbTileMap = TileMap:new("tilemaps/smb")
    game.level = Level:new("levels/1-1.json", smbTileMap)
    
    love.graphics.setBackgroundColor(game.level.backgroundColor or {92, 148, 252})
    
    game.coinFrame = 1
    game.coinAnimationTimer = 0
    game.timeLeft = 400

    playMusic(overworldMusic)

    skipUpdate()
end

function game.update(dt)
    game.timeLeft = math.max(0, game.timeLeft-2.5*dt)
    
    game.level:update(dt)
    
	game.coinAnimationTimer = game.coinAnimationTimer + dt
	while game.coinAnimationTimer >= COINANIMATIONTIME do
        game.coinFrame = game.coinFrame + 1
        
        if game.coinFrame > 5 then
            game.coinFrame = 1
        end

		game.coinAnimationTimer = game.coinAnimationTimer - COINANIMATIONTIME
	end
end

function game.draw()
    game.level:draw()
    
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
    game.level:keypressed(key)
end