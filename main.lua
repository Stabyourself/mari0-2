--Mari0 3DS - MIT License.

is3DS = love.system.getOS() == "Horizon"

function love.load()
    print("Mari0 3DS POC by Maurice")
    print("Loading stuff...")
    
    require "lib/3ds"
    require "variables"
    require "environment"
    
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    if not is3DS then
        love.window.setMode(400*SCALE, 480*SCALE)
    end
    
    JSON = require "lib/JSON"
    class = require "lib/Class"
    Camera = require "lib/Camera"
    FTAnalyser = require "lib/FTAnalyser"
    PerformanceTracker = require "lib/PerformanceTracker"

    require "enemyLoader"

    require "class/physics/World"
    require "class/physics/PhysObj"

    require "class/TileMap"
    require "class/Tile"
    require "class/Level"
    require "class/LevelCanvas"
    require "class/Mario"
    require "class/Block"
    require "class/BlockBounce"
    require "class/Enemy"

    require "game"
    
    love.graphics.set3D(true)
    
	fontImg = love.graphics.newImage("img/font.png")
	fontGlyphs = "0123456789abcdefghijklmnopqrstuvwxyz.:/,'C-_>* !{}?"
	fontQuad = {}
	for i = 1, string.len(fontGlyphs) do
		fontQuad[string.sub(fontGlyphs, i, i)] = love.graphics.newQuad((i-1)*8, 0, 8, 8, 512, 8)
	end

    print("Loading sound... (might take a while)")
    --overworldMusic = love.audio.newSource("sound/music/overworld.ogg")
    --overworldMusic:setLooping(true)

    jumpSound = love.audio.newSource("sound/jump.ogg")
    blockSound = love.audio.newSource("sound/block.ogg")
    coinSound = love.audio.newSource("sound/coin.ogg")
    stompSound = love.audio.newSource("sound/stomp.ogg")
    
    mainFTAnalyser = FTAnalyser:new()
    mainPerformanceTracker = PerformanceTracker:new()

    game.load()
end

function love.update(dt)
    mainFTAnalyser:frameStart()
    mainPerformanceTracker:reset()
    
    dt = math.min(1/10, dt)
    gdt = dt

    if skipNext then
        skipNext = false
        mainFTAnalyser:frameEnd(dt)
        return
    end

	if FFKEYS then
		for _, v in ipairs(FFKEYS) do
			if love.keyboard.isDown(v.key) then
				dt = dt * v.val
			end
		end
	end
    
    if gameState == "game" then
        game.update(dt)
    end
end

function love.draw()
    if SCALE ~= 1 then
        love.graphics.scale(SCALE, SCALE)
    end

    if gameState == "game" then
        game.draw()
    end
    
    mainFTAnalyser:frameEnd(gdt)

    love.graphics.setScreen("bottom")
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, BOTTOMSCREENWIDTH, BOTTOMSCREENHEIGHT)
    love.graphics.setColor(255, 255, 255)

    if keyDown("frameDataDisplay") then
        mainFTAnalyser:draw(0, 100, BOTTOMSCREENWIDTH, BOTTOMSCREENHEIGHT-100)
        mainPerformanceTracker:draw(0, 0)
    end
    
    love.graphics.setScreen("top")

    if SCALE ~= 1 then
        love.graphics.scale(1/SCALE, 1/SCALE)
    end
end

function love.keypressed(key)
    if key == CONTROLS.quit then
        love.event.quit()
    end
    
    if gameState == "game" then
        game.keypressed(key)
    end
end

function updateGroup(group, dt)
	local delete = {}
	
	for i, v in ipairs(group) do
		if v:update(dt) or v.deleteMe then
            v.deleteMe = true
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for _, v in ipairs(delete) do
		table.remove(group, v) --remove
	end
end

function keyDown(cmd)
    return love.keyboard.isDown(CONTROLS[cmd])
end

function skipUpdate()
    print("Skipping next update!")
    skipNext = true
end

function playMusic(music)
    playSound(music)
end

function playSound(sound)
    if not sound then
        print("Error playing some sound")
        return
    end
    
    sound:stop()
    sound:play()
end

function love.graphics.print(s, x, y, align, depth)
    love.graphics.setDepth(depth or 0)
    local len = string.len(tostring(s))
    
    if align == "center" then
        x = x - len*4
    elseif align == "right" then
        x = x - len*8
    end
    
	for i = 1, len do
		local quad = fontQuad[string.sub(s, i, i)]
        
		if quad then
			love.graphics.draw(fontImg, quad, (x+(i-1)*8), y, 0, 1, 1)
		end
	end
    
    love.graphics.setDepth(0)
end

function print_r (t, indent) --Not by me
	local indent=indent or ''
	for key,value in pairs(t) do
		io.write(indent,'[',tostring(key),']') 
		if type(value)=="table" then io.write(':\n') print_r(value,indent..'\t')
		else io.write(' = ',tostring(value),'\n') end
	end
end

function padZeroes(s, num)
    return string.format("%0" .. num .. "d", s)
end

function inTable(t, needle)
	for i, v in pairs(t) do
		if v == needle then
			return true
		end
	end
	return false
end

function worldDraw(...)
    local arg = {...}

    if type(arg[2]) == "number" then
        love.graphics.draw(arg[1], math.round(arg[2]*TILESIZE), math.round(arg[3]*TILESIZE), arg[4], arg[5], arg[6], arg[7], arg[8])
    else
        love.graphics.draw(arg[1], arg[2], math.round(arg[3]*TILESIZE), math.round(arg[4]*TILESIZE), arg[5], arg[6], arg[7], arg[8], arg[9])
    end
end

function math.round(i, decimals)
    local factor = math.pow(10, decimals or 0)
    
    if i > 0 then
        return math.floor(i*factor+.5)/factor
    else
        return math.ceil(i*factor-.5)/factor
    end
end

function getRequiredSpeed(height, gravity)
    return math.sqrt(2*(gravity or GRAVITY)*height)
end

function math.clamp(n, low, high) 
    return math.min(math.max(low, n), high) 
end

function drawOverBlock(x, y)
    love.graphics.setColor(love.graphics.getBackgroundColor())
    love.graphics.rectangle("fill", (x-1)*TILESIZE, (y-1)*TILESIZE, TILESIZE, TILESIZE)
    love.graphics.setColor(255, 255, 255)
end