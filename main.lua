--Mari3 - MIT License.
function love.load()
    print("Mari3 POC by Maurice")
    print("Loading stuff...")
    
    require "util"
    
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    love.window.setMode(400*VAR("scale"), 224*VAR("scale"), {
        vsync = false,
        resizable = true,
    })
    
    love.resize(400*VAR("scale"), 224*VAR("scale"))
    
    sandbox = require "lib/sandbox"
    JSON = require "lib/JSON"
    class = require "lib/middleclass"
    Camera = require "lib/Camera"

    require "lib/fissix"

    require "class/CharacterState"
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
        .;:;!?_-<>=+*/\
    ]]
    
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
            if byte == string.byte(";") and inLongName then
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
    if not VAR("musicDisabled") then
        overworldMusic = love.audio.newSource("sound/music/overworld.ogg")
        overworldMusic:setLooping(true)
        overworldMusic:setVolume(VAR("volume"))
    end

    jumpSound = love.audio.newSource("sound/jump.ogg")
    jumpSound:setVolume(VAR("volume"))
    blockSound = love.audio.newSource("sound/block.ogg")
    blockSound:setVolume(VAR("volume"))
    coinSound = love.audio.newSource("sound/coin.ogg")
    coinSound:setVolume(VAR("volume"))
    stompSound = love.audio.newSource("sound/stomp.ogg")
    stompSound:setVolume(VAR("volume"))
    
    defaultUI = UI:new("img/ui/default.png")

    print("Loading game")
    game.load()
end

function love.update(dt)
    dt = math.min(1/10, dt)
    gdt = dt

    if skipNext then
        skipNext = false
        return
    end

	if VAR("ffKeys") then
        for _, v in ipairs(VAR("ffKeys")) do
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
    if VAR("scale") ~= 1 then
        love.graphics.scale(VAR("scale"), VAR("scale"))
    end

    if gameState == "game" then
        game.draw()
    end
    
    marioPrint(game.level.marios[1].state.name, 8, 8)
    marioPrint("Spinning:    " .. tostring(game.level.marios[1].spinning), 8, 18)
    marioPrint("Shooting:    " .. tostring(game.level.marios[1].shooting), 8, 28)
    
    -- For the stream
    if VAR("inputDebug") then
        local function setColorBasedOn(key)
            if keyDown(key) then
                love.graphics.setColor(255, 255, 255)
            else
                love.graphics.setColor(50, 50, 50)
            end
        end
        
        setColorBasedOn("up")
        love.graphics.rectangle("fill", 16, SCREENHEIGHT-32, 8, 8)
        setColorBasedOn("left")
        love.graphics.rectangle("fill", 8, SCREENHEIGHT-24, 8, 8)
        setColorBasedOn("right")
        love.graphics.rectangle("fill", 24, SCREENHEIGHT-24, 8, 8)
        setColorBasedOn("down")
        love.graphics.rectangle("fill", 16, SCREENHEIGHT-16, 8, 8)
        
        setColorBasedOn("run")
        love.graphics.rectangle("fill", 60, SCREENHEIGHT-20, 8, 8)
        setColorBasedOn("jump")
        love.graphics.rectangle("fill", 72, SCREENHEIGHT-20, 8, 8)
        
        
        love.graphics.setColor(255, 255, 255)
    end

    if VAR("scale") ~= 1 then
        love.graphics.scale(1/VAR("scale"), 1/VAR("scale"))
    end
end

function love.keypressed(key)
    if key == VAR("controls").quit then
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
    SCREENWIDTH = w/VAR("scale")
    SCREENHEIGHT = h/VAR("scale")
    
    CAMERAWIDTH = SCREENWIDTH
    CAMERAHEIGHT = SCREENHEIGHT-VAR("uiHeight")-VAR("uiLineHeight")

    WIDTH = math.ceil(CAMERAWIDTH/VAR("tileSize"))
    HEIGHT = math.ceil(CAMERAHEIGHT/VAR("tileSize"))
    
    RIGHTSCROLLBORDER = math.floor(math.max(CAMERAWIDTH/2, CAMERAWIDTH-VAR("cameraScrollRightBorder")))
    LEFTSCROLLBORDER = math.ceil(math.min(CAMERAWIDTH/2, VAR("cameraScrollLeftBorder")))
    
    DOWNSCROLLBORDER = math.floor(math.max(CAMERAHEIGHT/2, CAMERAHEIGHT-VAR("cameraScrollDownBorder")))
    print(DOWNSCROLLBORDER, CAMERAHEIGHT-VAR("cameraScrollDownBorder"))
    UPSCROLLBORDER = math.ceil(math.min(CAMERAHEIGHT/2, VAR("cameraScrollUpBorder")))
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
                toPrint = string.lower(glyph)
            end
        end
        
        if toPrint then
            love.graphics.draw(fontImg, fontQuad[toPrint], char*8+x, y)
            char = char + 1
        end
    end
end

function keyDown(cmd)
    return love.keyboard.isDown(VAR("controls")[cmd])
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
    love.graphics.line(x1*VAR("tileSize"), y1*VAR("tileSize"), x2*VAR("tileSize"), y2*VAR("tileSize"))
end

function worldRectangle(style, x, y, w, h)
    love.graphics.rectangle(style, x*VAR("tileSize"), y*VAR("tileSize"), w*VAR("tileSize"), h*VAR("tileSize"))
end

function worldPolygon(style, ...)
    local points = {}
    
    for i, v in ipairs({...}) do
       table.insert(points, v*VAR("tileSize"))
    end
    
    love.graphics.polygon(style, unpack(points))
end

function worldArrow(x, y, xDir, yDir)
    local scale = math.sqrt(xDir^2+yDir^2)/8
    local angle = math.atan2(yDir, xDir)
    local arrowTipScale = 0.2
    
    --body
    local x2, y2 = x+math.cos(angle)*scale, y+math.sin(angle)*scale
    
    love.graphics.line(x, y, x2, y2)
    
    --tipleft
    local x3, y3 = x2+math.cos(angle-math.pi*0.75)*scale*arrowTipScale, y2+math.sin(angle-math.pi*0.75)*scale*arrowTipScale
    love.graphics.line(x2, y2, x3, y3)
    
    --tipright
    local x4, y4 = x2+math.cos(angle+math.pi*0.75)*scale*arrowTipScale, y2+math.sin(angle+math.pi*0.75)*scale*arrowTipScale
    love.graphics.line(x2, y2, x4, y4)
end
