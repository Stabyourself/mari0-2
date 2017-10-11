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
        love.window.setMode(400*SCALE, 240*SCALE)
    end
    
    JSON = require "lib/JSON"
    class = require "lib/Class"
    Camera = require "lib/Camera"
    FTAnalyser = require "lib/FTAnalyser"
    PerformanceTracker = require "lib/PerformanceTracker"

    require "lib/fissix"

    require "enemyLoader"

    require "class/Level"
    require "class/WorldCanvas"
    require "class/Mario"
    require "class/BlockBounce"
    require "class/Enemy"
    require "class/Portal" -- the juicy bits
    require "class/PortalWall"

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
    jumpSound:setVolume(VOLUME)
    blockSound = love.audio.newSource("sound/block.ogg")
    blockSound:setVolume(VOLUME)
    coinSound = love.audio.newSource("sound/coin.ogg")
    coinSound:setVolume(VOLUME)
    stompSound = love.audio.newSource("sound/stomp.ogg")
    stompSound:setVolume(VOLUME)
    
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
    if SCALE ~= 1 and not is3DS then
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

    if SCALE ~= 1 and not is3DS then
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
		table.remove(group, v)
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
        love.graphics.draw(arg[1], math.round(arg[2]), math.round(arg[3]), arg[4], arg[5], arg[6], arg[7], arg[8])
    else
        love.graphics.draw(arg[1], arg[2], math.round(arg[3]), math.round(arg[4]), arg[5], arg[6], arg[7], arg[8], arg[9])
    end
end

function worldLine(x1, y1, x2, y2)
    love.graphics.line(x1*TILESIZE, y1*TILESIZE, x2*TILESIZE, y2*TILESIZE)
end

function worldRectangle(style, x, y, w, h)
    love.graphics.rectangle(style, x*TILESIZE, y*TILESIZE, w*TILESIZE, h*TILESIZE)
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
    return math.max(math.min(high, n), low) 
end

function drawOverBlock(x, y)
    love.graphics.setColor(game.level.backgroundColor)
    love.graphics.rectangle("fill", (x-1)*TILESIZE, (y-1)*TILESIZE, TILESIZE, TILESIZE)
    love.graphics.setColor(255, 255, 255)
end

function sideOfLine(ox, oy, p1x, p1y, p2x, p2y) -- Credits to https://stackoverflow.com/a/293052
    return (p2y-p1y)*ox + (p1x-p2x)*oy + (p2x*p1y-p1x*p2y)
end

function rectangleOnLine(x, y, w, h, p1x, p1y, p2x, p2y) -- Todo: optimize this
    -- A
    local pointPositions = {
        sideOfLine(x, y, p1x, p1y, p2x, p2y),
        sideOfLine(x+w, y, p1x, p1y, p2x, p2y),
        sideOfLine(x, y+h, p1x, p1y, p2x, p2y),
        sideOfLine(x+w, y+h, p1x, p1y, p2x, p2y)
    }

    local above, below = false, false

    for i = 1, 4 do
        if pointPositions[i] > 0 then
            above = true
        elseif pointPositions[i] < 0 then
            below = true
        end
    end

    if above and below then
        -- B
        local angle = math.atan2(p2y-p1y, p2x-p1x)
        local newX = pointAroundPoint(x, y, p1x, p1y, -angle) - p1x
        
        if newX > -0.1 and newX < 1.9 then -- These values may need to be reworked properly
            return true
        end
    end

    return false
end

function linesIntersect(p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y) -- Credits to https://stackoverflow.com/a/1968345
    local s0x = p2x - p1x 
    local s0y = p2y - p1y

    local s2_x = p4x - p3x  
    local s2_y = p4y - p3y

    local s = (-s0y * (p1x - p3x) + s0x * (p1y - p3y)) / (-s2_x * s0y + s0x * s2_y)
    local t = ( s2_x * (p1y - p3y) - s2_y * (p1x - p3x)) / (-s2_x * s0y + s0x * s2_y)

    if (s >= 0 and s <= 1 and t >= 0 and t <= 1) then
        return p1x + (t * s0x), p1y + (t * s0y)
    end

    return false
end

function pointAroundPoint(x1, y1, x2, y2, r) -- Credits to https://stackoverflow.com/a/15109215
    local newX = math.cos(r) * (x1-x2) - math.sin(r) * (y1-y2) + x2
    local newY = math.sin(r) * (x1-x2) + math.cos(r) * (y1-y2) + y2

    return newX, newY
end
