--Mari3 - MIT License.
function love.load()
    print("Mari3 POC by Maurice")
    print("Loading stuff...")
    
    require "variables"
    if love.filesystem.exists("environment.lua") then
        require "environment"
    end
    
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    love.window.setMode(400*SCALE, 224*SCALE, {
        vsync = false,
        resizable = true,
    })
    
    love.resize(400*SCALE, 224*SCALE)
    
    require "util"
    sandbox = require "lib/sandbox"
    JSON = require "lib/JSON"
    class = require "lib/middleclass"
    Camera = require "lib/Camera"
    FTAnalyser = require "lib/FTAnalyser"
    PerformanceTracker = require "lib/PerformanceTracker"

    require "lib/fissix"

    require "class/Character"
    require "enemyLoader"

    require "class/Level"
    require "class/Mario"
    require "class/BlockBounce"
    require "class/Enemy"
    require "class/Portal" -- the juicy bits
    require "class/UI"
    require "class/Smb3Ui"

    require "game"
    
	fontImg = love.graphics.newImage("img/font.png")
    fontGlyphs = [[
        0123456789ab
        cdefghijklmn
        opqrstuvwxyz
        &pMeterTick;
        &pMeterTickOn;
        &World1;
        &World2;
        &World3;
        &World4;
        &pMeter1;
        &pMeter2;
        &pMeterOn1;
        &pMeterOn2;
        &Mario1;
        &Mario2;
        &Luigi1;
        &Luigi2;
        &Dollarinos;
        &Time;
        &Times;
        &Space;
    ]]
    
    fontIgnore = {32}
    
    local i = 1
    local glyphNum = 1
    local inLongName = false
    local currentGlyph = ""
    local glyphSize = 8
    local glyphWidth = fontImg:getWidth()/glyphSize
    fontQuad = {}
    
    local function assignGlyph(glyph)
        local x = math.floor((glyphNum-1)%glyphWidth+1)
        local y = math.ceil(glyphNum/glyphWidth)
        
        fontQuad[glyph] = love.graphics.newQuad((x-1)*glyphSize, (y-1)*glyphSize, glyphSize, glyphSize, fontImg:getWidth(), fontImg:getHeight())
        
        glyphNum = glyphNum + 1
    end
    
    for i = 1, #fontGlyphs do
        local glyph = string.sub(fontGlyphs, i, i)
        local byte = string.byte(glyph)
        
        if byte ~= string.byte("\n") and byte ~= string.byte(" ") then
            if byte == string.byte(";") then
                if inLongName then
                    assignGlyph(currentGlyph)
                    currentGlyph = ""
                    inLongName = false
                end
            elseif byte == string.byte("&") then
                inLongName = true
                currentGlyph = ""
            else
                if inLongName then
                    currentGlyph = currentGlyph .. glyph
                else
                    assignGlyph(glyph)
                end
            end
        end
    end
    
    fontQuad[" "] = fontQuad["Space"]

    print("Loading sound... (might take a while)")
    if not MUSICDISABLED then
        overworldMusic = love.audio.newSource("sound/music/overworld.ogg")
        overworldMusic:setLooping(true)
    end

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
    
    defaultUI = UI:new("img/ui/default.png")

    print("Loading game")
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

function love.mousepressed(x, y, button)
    if gameState == "game" then
        game.mousepressed(x, y, button)
    end
end

function love.resize(w, h)
    SCREENWIDTH = w/SCALE
    SCREENHEIGHT = h/SCALE

    WIDTH = math.ceil(SCREENWIDTH/TILESIZE)
    HEIGHT = math.ceil((SCREENHEIGHT-UIHEIGHT)/TILESIZE)

    SCROLLINGSTART = math.max(5, WIDTH-13) --when the scrolling begins to set in
    SCROLLINGCOMPLETE = math.max(2, WIDTH-10) --when the scrolling will be as fast as mario can run

    SCROLLINGLEFTSTART = 6 --See above, but for scrolling left
    SCROLLINGLEFTCOMPLETE = 4
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

function marioPrint(s, x, y)
    local longGlyph = false
    local char = 0
    for i = 1, #s do
        local toPrint = false
        local glyph = string.sub(s, i, i)
        local byte = string.byte(glyph)
        
        if byte == string.byte("&") then
            longGlyph = ""
        elseif byte == string.byte(";") and longGlyph then
            toPrint = longGlyph
            longGlyph = false
        else
            if longGlyph then
                longGlyph = longGlyph .. glyph
            else
                toPrint = glyph
            end
        end
        
        if toPrint then
            love.graphics.draw(fontImg, fontQuad[toPrint], char*8+x, y)
            char = char + 1
        end
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

function love.graphics.print(s, x, y, align)
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

function worldPolygon(style, ...)
    local points = {}
    
    for i, v in ipairs({...}) do
       table.insert(points, v*TILESIZE)
    end
    
    love.graphics.polygon(style, unpack(points))
end
