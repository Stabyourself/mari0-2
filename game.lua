game = {}

function game.load()
    gameState = "game"
    
    game.coinAnimationFrame = 1
    game.coinAnimationTimer = 0
    game.timeLeft = 400
    
    smbTileMap = fissix.TileMap:new("tilemaps/smb3")
    SmbMario = require("characters/smb-mario/code")
    Smb3Mario = require("characters/smb3-mario/code")
    
    game.level = Level:new("levels/smb3test.lua", smbTileMap)
    
    smb3ui = Smb3Ui:new()
    
    love.graphics.setBackgroundColor(game.level.backgroundColor)

    if not VAR("musicDisabled") then
        playMusic(overworldMusic)
    end

    skipUpdate()
end

function game.update(dt)
    game.timeLeft = math.max(0, game.timeLeft-2.5*dt)
    
    game.level:update(dt)
    
    if game.level.marios[1].y > game.level.height*game.level.tileMap.tileSize+.5 then
        game.level.marios[1].y = -1
    end
    
	game.coinAnimationTimer = game.coinAnimationTimer + dt
	while game.coinAnimationTimer >= VAR("coinAnimationTime") do
        game.coinAnimationFrame = game.coinAnimationFrame + 1
        
        if game.coinAnimationFrame > 5 then
            game.coinAnimationFrame = 1
        end

		game.coinAnimationTimer = game.coinAnimationTimer - VAR("coinAnimationTime")
    end
    
    smb3ui:update(dt)
end

function game.draw()
    game.level:draw()

    love.graphics.setColor(255, 255, 255)
    smb3ui.time = math.floor(love.timer.getFPS())--math.ceil(game.timeLeft)
    smb3ui.pMeter = game.level.marios[1].pMeter
    smb3ui.score = 160291
    smb3ui.lives = 4
    smb3ui.coins = 23
    smb3ui.world = 1
    smb3ui:draw()
    
    -- UI
    -- score
    
    --[[
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
    --]]
end

function game.keypressed(key)
    game.level:keypressed(key)
end

function game.mousepressed(x, y, button)
    game.level:mousepressed(x, y, button)
end