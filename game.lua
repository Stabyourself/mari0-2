game = {}

function game.load()
    gameState = "game"
    
    game.coinAnimationFrame = 1
    game.coinAnimationTimer = 0
    game.timeLeft = 400
    
    smb3TileMap = fissix.TileMap:new("tilemaps/smb3")
    SmbMario = require("characters/smb-mario/code")
    Smb3Mario = require("characters/smb3-mario/code")
    
    game.level = Level:new("levels/smb3test.lua", smb3TileMap)
    
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

    love.graphics.setColor(1, 1, 1)
    smb3ui.time = math.floor(love.timer.getFPS())--math.ceil(game.timeLeft)
    smb3ui.pMeter = game.level.marios[1].pMeter
    smb3ui.score = 160291
    smb3ui.lives = 4
    smb3ui.coins = 23
    smb3ui.world = 1
    smb3ui:draw()
end

function game.resize(w, h)
    smb3ui:resize(w, h)
end

function game.keypressed(key)
    game.level:keypressed(key)
end

function game.mousepressed(x, y, button)
    game.level:mousepressed(x, y, button)
end