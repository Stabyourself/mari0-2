-- Stubs for testing
love.graphics.set3D = love.graphics.set3D or function() end
love.graphics.setDepth = love.graphics.setDepth or function() end

is3DS = love.system.getOS() == "Horizon"

function love.load()
    print("Mari0 3DS POC by Maurice")
    print("Loading stuff...")

    JSON = require "lib/JSON"
    class = require "lib/Class"
    Camera = require "lib/camera"

    require "variables"
    require "environment"

    require "class/physics/World"
    require "class/physics/PhysObj"

    require "class/TileMap"
    require "class/Tile"
    require "class/Level"
    require "class/Mario"
    require "class/Block"

    require "game"
    
    love.graphics.set3D(true)
    
	fontImg = love.graphics.newImage("img/font.png")
	fontGlyphs = "0123456789abcdefghijklmnopqrstuvwxyz.:/,'C-_>* !{}?"
	fontQuad = {}
	for i = 1, string.len(fontGlyphs) do
		fontQuad[string.sub(fontGlyphs, i, i)] = love.graphics.newQuad((i-1)*8, 0, 8, 8, 512, 8)
	end

    print("Loading sound... (might take a while)")
    overworldMusic = love.audio.newSource("sound/music/overworld.ogg")
    overworldMusic:setLooping(true)

    jumpSound = love.audio.newSource("sound/jump.ogg")
    blockSound = love.audio.newSource("sound/block.ogg") -- Kick punch block!

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
    skipNext = true
end

function playMusic(music)
    playSound(music)
end

function playSound(sound)
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
			love.graphics.draw(fontImg, quad, x+(i-1)*8, y)
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
