--Mari3 - MIT License.
function love.load()
    print("Mari3 POC by Stabyourself.net")
    
    require "util"
    
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    love.window.setMode(400*VAR("scale"), 224*VAR("scale"), {
        vsync = VAR("vsync"),
        resizable = true,
    })
    
    sandbox = require "lib/sandbox"
    JSON = require "lib/JSON"
    class = require "lib/middleclass"
    Camera = require "lib/Camera"
    Color = require "lib/Color"
    Easing = require "lib/Easing"

    require "class/fissix"

    require "class/CharacterState"
    require "class/Character"
    require "enemyLoader"

    require "class/Level"
    require "class/Mario"
    require "class/BlockBounce"
    require "class/Enemy"
    require "class/Portal" -- the juicy bits
    require "class/PortalParticle" -- the juicy bits
    require "class/gui"
    require "class/Smb3Ui"
    
    require "cheats"

    require "gameStateManager"
    
    require "game"
    require "editor"
    
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
        .;:;!?_-<>=+*/\'
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
        overworldMusic = love.audio.newSource("sound/music/overworld.ogg", "stream")
        overworldMusic:setLooping(true)
        overworldMusic:setVolume(VAR("volume"))
    end

    jumpSound = love.audio.newSource("sound/jump.ogg", "static")
    jumpSound:setVolume(VAR("volume"))
    blockSound = love.audio.newSource("sound/block.ogg", "static")
    blockSound:setVolume(VAR("volume"))
    coinSound = love.audio.newSource("sound/coin.ogg", "static")
    coinSound:setVolume(VAR("volume"))
    stompSound = love.audio.newSource("sound/stomp.ogg", "static")
    stompSound:setVolume(VAR("volume"))

    debugCandyImg = love.graphics.newImage("img/debug-candy.png")
    debugCandyImg:setWrap("repeat")
    
    defaultUI = GUI:new("img/gui/default")
    
    love.resize(400*VAR("scale"), 224*VAR("scale"))

    print("Loading game")
    gameStateManager.loadState(game)
    gameStateManager.addState(editor)
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
    
    gameStateManager.event("update", dt)
end

function love.draw()
    if VAR("scale") ~= 1 then
        love.graphics.scale(VAR("scale"), VAR("scale"))
    end
    
    gameStateManager.event("draw")
    
    if VAR("characterStateDebug") then
        marioPrint(game.level.marios[1].state.name, 8, 8)
    end
    
    -- For the stream
    if VAR("inputDebug") then
        local function setColorBasedOn(key)
            if keyDown(key) then
                love.graphics.setColor(1, 1, 1)
            else
                love.graphics.setColor(0.2, 0.2, 0.2)
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
        
        
        love.graphics.setColor(1, 1, 1)
    end

    if VAR("scale") ~= 1 then
        love.graphics.scale(1/VAR("scale"), 1/VAR("scale"))
    end
end

function love.keypressed(key)
    if key == VAR("controls").quit then
        love.event.quit()
    end
    
    gameStateManager.event("keypressed", key)
end

function getWorldMouse()
    return love.mouse.getX()/VAR("scale"), love.mouse.getY()/VAR("scale")
end

function love.mousepressed(x, y, button)
    x, y = getWorldMouse()
    
    gameStateManager.event("mousepressed", x, y, button)
end

function love.mousereleased(x, y, button)
    x, y = getWorldMouse()
    
    gameStateManager.event("mousereleased", x, y, button)
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
    UPSCROLLBORDER = math.ceil(math.min(CAMERAHEIGHT/2, VAR("cameraScrollUpBorder")))

    debugCandyQuad = love.graphics.newQuad(0, 0, SCREENWIDTH, SCREENHEIGHT, 8, 8)
    
    gameStateManager.event("resize", SCREENWIDTH, SCREENHEIGHT)
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
    
    local charX = 0
    local charY = 0
    
    for i = 1, #s do
        local toPrint = false
        local glyph = string.sub(s, i, i)
        local byte = string.byte(glyph)
        
        if byte == string.byte("&") then
            longGlyph = ""
        elseif byte == string.byte(";") and longGlyph then
            toPrint = longGlyph
            longGlyph = false
        elseif byte == string.byte("\n") then
            charY = charY + 1
            charX = 0
        else
            if longGlyph then
                longGlyph = longGlyph .. glyph
            else
                toPrint = string.lower(glyph)
            end
        end
        
        if toPrint then
            love.graphics.draw(fontImg, fontQuad[toPrint], charX*8+x, charY*8+y)
            charX = charX + 1
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
        if VAR("noSubpixelMovement") then
            arg[2] = math.round(arg[2])
            arg[3] = math.round(arg[3])
        end
        
        love.graphics.draw(arg[1], arg[2], arg[3], arg[4], arg[5], arg[6], arg[7], arg[8])
    else
        if VAR("noSubpixelMovement") then
            arg[3] = math.round(arg[3])
            arg[4] = math.round(arg[4])
        end
        
        love.graphics.draw(arg[1], arg[2], arg[3], arg[4], arg[5], arg[6], arg[7], arg[8], arg[9])
    end
end

function worldLine(x1, y1, x2, y2)
    love.graphics.line(x1, y1, x2, y2)
end

function worldRectangle(style, x, y, w, h)
    if VAR("noSubpixelMovement") then
        x = math.round(x)
        y = math.round(y)
        w = math.round(w)
        h = math.round(h)
    end
    love.graphics.rectangle(style, x, y, w, h)
end

function worldPolygon(style, ...)
    local points = {}
    
    for i, v in ipairs({...}) do
       table.insert(points, v)
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
