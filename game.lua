game = {}

function game.load()
    if not is3DS then
        love.window.setMode(416, 480)
    end
    
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
    game.level:draw(mainCamera)
    
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