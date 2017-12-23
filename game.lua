game = {}

function game.load()
    gameState = "game"
    
    game.coinAnimationFrame = 1
    game.coinAnimationTimer = 0
    game.timeLeft = 400
    
    smbTileMap = fissix.TileMap:new("tilemaps/smb3")
    smb3_mario = Character:new("characters/smb3-mario")
    game.level = Level:new("levels/smb3test.lua", smbTileMap)
    
    love.graphics.setBackgroundColor(game.level.backgroundColor)

    if not MUSICDISABLED then
        playMusic(overworldMusic)
    end

    skipUpdate()
end

function game.update(dt)
    game.timeLeft = math.max(0, game.timeLeft-2.5*dt)
    
    game.level:update(dt)
    
    if game.level.marios[1].y > HEIGHT*game.level.tileMap.tileSize+.5 then
        game.level.marios[1].y = -1
    end
    
	game.coinAnimationTimer = game.coinAnimationTimer + dt
	while game.coinAnimationTimer >= COINANIMATIONTIME do
        game.coinAnimationFrame = game.coinAnimationFrame + 1
        
        if game.coinAnimationFrame > 5 then
            game.coinAnimationFrame = 1
        end

		game.coinAnimationTimer = game.coinAnimationTimer - COINANIMATIONTIME
	end
end

function game.draw()
    game.level:draw()

    love.graphics.setColor(255, 255, 255)
    
    -- UI
    -- score
    love.graphics.print("mario", 24, 16, "left")
    love.graphics.print("012345", 24, 24, "left")
    
    -- coins (abused as FPS for now)
    love.graphics.print("fps*" .. love.timer.getFPS(), math.round((SCREENWIDTH-80)/3)+40, 24, "center")
    
    -- level
    love.graphics.print("world", math.round((SCREENWIDTH-80)/3*2)+40, 16, "center")
    love.graphics.print(" 1-1 ", math.round((SCREENWIDTH-80)/3*2)+40, 24, "center")
    
    -- time
    love.graphics.print("time", SCREENWIDTH-24, 16, "right")
    love.graphics.print(padZeroes(math.ceil(game.timeLeft), 3), SCREENWIDTH-24, 24, "right")
end

function game.keypressed(key)
    game.level:keypressed(key)
end

function game.mousepressed(x, y, button)
    game.level:mousepressed(x, y, button)
end