-- Stubs for testing
love.graphics.set3D = love.graphics.set3D or function() end
love.graphics.setDepth = love.graphics.setDepth or function() end

is3DS = love.system.getOS() == "Horizon"

function love.load()
    print("Mari0 3DS POC by Maurice")
    print("Loading stuff...")
    
    require "variables"
    require "environment"
    
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    if not is3DS then
        love.window.setMode(400*SCALE, 240*SCALE)
    end
    
    JSON = require "lib/JSON"
    class = require "lib/Class"
    Camera = require "lib/camera"

    require "enemyLoader"

    require "class/physics/World"
    require "class/physics/PhysObj"

    require "class/TileMap"
    require "class/Tile"
    require "class/Level"
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

    print("Alright let's go!")

    game.load()
end

function love.update(dt)
    dt = math.min(1/10, dt)

    if skipNext then
        skipNext = false
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
    if gameState == "game" then
        game.draw()
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

function marioPrint(s, x, y, align, depth)
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
			love.graphics.draw(fontImg, quad, (x+(i-1)*8)*SCALE, y*SCALE, 0, SCALE, SCALE)
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
        love.graphics.draw(arg[1], round(arg[2]*TILESIZE)*SCALE, round(arg[3]*TILESIZE)*SCALE, (arg[4] or 0), (arg[5] or 1)*SCALE, (arg[6] or 1)*SCALE, arg[7], arg[8])
    else
        love.graphics.draw(arg[1], arg[2], round(arg[3]*TILESIZE)*SCALE, round(arg[4]*TILESIZE)*SCALE, (arg[5] or 0), (arg[6] or 1)*SCALE, (arg[7] or 1)*SCALE, arg[8], arg[9])
    end
end

function round(i)
    if i > 0 then
        return math.floor(i+.5)
    else
        return math.ceil(i-.5)
    end
end

function getRequiredSpeed(height, gravity)
    return math.sqrt(2*(gravity or GRAVITY)*height)
end
