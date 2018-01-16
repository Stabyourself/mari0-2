--Mari3 - MIT License.
function love.load()
    print("Mari3 POC by Stabyourself.net")
    
    require "util"
    
    love.window.setMode(400*VAR("scale"), 224*VAR("scale"), {
        vsync = VAR("vsync"),
        resizable = true,
        msaa = msaa,
        minwidth = 232*VAR("scale"),
        minheight = 165*VAR("scale"),
    })

    love.window.setTitle("Definitely not Mari0 2")
    
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    sandbox = require "lib.sandbox"
    JSON = require "lib.JSON"
    class = require "lib.middleclass"
    Camera = require "lib.Camera"
    Color = require "lib.Color"
    Easing = require "lib.Easing"
    GameStateManager = require "lib.GameStateManager"
    Font3 = require "lib.Font3"

    require "class.fissix"

    require "class.CharacterState"
    require "class.Character"
    require "enemyLoader"

    require "class.Level"
    require "class.Mario"
    require "class.BlockBounce"
    require "class.Enemy"
    require "class.Portal"
    require "class.PortalParticle"
    require "class.gui"
    require "class.Smb3Ui"
    require "class.Crosshair"
    require "class.EditorState"
    require "class.Selection"
    
    require "cheats"
    
    require "state.Game"
    require "state.Editor"
    
    fontOutlined = Font3:new(love.graphics.newImage("img/font-outlined.png"), [[
        ABCDEFGHIJKLMNOPQRSTUVWXYZ
        abcdefghijklmnopqrstuvwxyz
        0123456789
        &Space;
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
        .;:;!?_-<>=+*/\'%
    ]])
    
    font = Font3:new(love.graphics.newImage("img/font.png"), [[
        ABCDEFGHIJKLMNOPQRSTUVWXYZ
        abcdefghijklmnopqrstuvwxyz
        0123456789
        &Space;
        .;:;!?_-<>=+*/\'%
        &Intersect;
    ]])

    debugCandyImg = love.graphics.newImage("img/debug-candy.png")
    debugCandyImg:setWrap("repeat")
    
    defaultUI = GUI:new("img/gui/default")
    
    gameStateManager = GameStateManager:new()
    
    love.resize(400*VAR("scale"), 224*VAR("scale"))

    game = Game:new()

    gameStateManager:loadState(game)
    gameStateManager:addState(Editor:new(game.level))
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
    
    gameStateManager:event("update", dt)
end

local function setColorBasedOn(key)
    if cmdDown(key) then
        love.graphics.setColor(1, 1, 1)
    else
        love.graphics.setColor(0.2, 0.2, 0.2)
    end
end

function love.draw()
    if VAR("scale") ~= 1 then
        love.graphics.scale(VAR("scale"), VAR("scale"))
    end
    
    gameStateManager:event("draw")
    
    if VAR("characterStateDebug") then
        fontOutlined:print(game.level.marios[1].state.name, 8, 8)
    end
    
    -- For the stream
    if VAR("inputDebug") then
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

function appendCmds(cmds, t)
    if type(t) == "string" then
        cmds[t] = true
    elseif type(t) == "table" then
        for _, v in ipairs(t) do
            cmds[v] = true
        end
    end
end

function love.keypressed(key)
    -- Convert the key to its binding
    -- ^ctrl !alt +shift
    
    local cmds = {}
    local sendCmds = false
    if CONTROLS(key) then
        appendCmds(cmds, CONTROLS(key))
        sendCmds = true
    end

    if love.keyboard.isDown({"lctrl", "rctrl"}) and CONTROLS("^" .. key) then
        appendCmds(cmds, CONTROLS("^" .. key))
        sendCmds = true
    end

    if love.keyboard.isDown({"lalt", "ralt"}) and CONTROLS("!" .. key) then
        appendCmds(cmds, CONTROLS("!" .. key))
        sendCmds = true
    end

    if love.keyboard.isDown({"lshift", "rshift"}) and CONTROLS("+" .. key) then
        appendCmds(cmds, CONTROLS("+" .. key))
        sendCmds = true
    end
    
    if cmds["quit"] then
        love.event.quit()
        return
    end
    
    if sendCmds then
        gameStateManager:event("cmdpressed", cmds)
    end
    gameStateManager:event("keypressed", key)
end

function getWorldMouse()
    return love.mouse.getX()/VAR("scale"), love.mouse.getY()/VAR("scale")
end

function love.mousepressed(x, y, button)
    x, y = getWorldMouse()
    
    gameStateManager:event("mousepressed", x, y, button)
end

function love.mousereleased(x, y, button)
    x, y = getWorldMouse()
    
    gameStateManager:event("mousereleased", x, y, button)
end

function love.resize(w, h)
    SCREENWIDTH = w/VAR("scale")
    SCREENHEIGHT = h/VAR("scale")
    
    updateSizes()
    
    gameStateManager:event("resize", SCREENWIDTH, SCREENHEIGHT)
end

function updateSizes()
    CAMERAWIDTH = SCREENWIDTH
    CAMERAHEIGHT = SCREENHEIGHT
    
    if not game or game.uiVisible then
        CAMERAHEIGHT = CAMERAHEIGHT-VAR("uiLineHeight")-VAR("uiHeight")
    end

    WIDTH = math.ceil(CAMERAWIDTH/VAR("tileSize"))
    HEIGHT = math.ceil(CAMERAHEIGHT/VAR("tileSize"))
    
    RIGHTSCROLLBORDER = math.floor(math.max(CAMERAWIDTH/2, CAMERAWIDTH-VAR("cameraScrollRightBorder")))
    LEFTSCROLLBORDER = math.ceil(math.min(CAMERAWIDTH/2, VAR("cameraScrollLeftBorder")))
    
    DOWNSCROLLBORDER = math.floor(math.max(CAMERAHEIGHT/2, CAMERAHEIGHT-VAR("cameraScrollDownBorder")))
    UPSCROLLBORDER = math.ceil(math.min(CAMERAHEIGHT/2, VAR("cameraScrollUpBorder")))

    debugCandyQuad = love.graphics.newQuad(0, 0, SCREENWIDTH, SCREENHEIGHT, 8, 8)
end

function love.wheelmoved(x, y)
    gameStateManager:event("wheelmoved", x, y)
end

function updateGroup(group, dt)
	local delete = {}
	
	for i, v in ipairs(group) do
		if v:update(dt) or v.deleteMe then
            v.deleteMe = true
			table.insert(delete, i)
		end
	end
	
	for i = #delete, 1, -1 do
		table.remove(group, delete[i])
	end
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
        -- arg[2] = math.round(arg[2]*VAR("scale"))/VAR("scale")
        -- arg[3] = math.round(arg[3]*VAR("scale"))/VAR("scale")
        
        love.graphics.draw(arg[1], arg[2], arg[3], arg[4], arg[5], arg[6], arg[7], arg[8])
    else
        -- arg[3] = math.round(arg[3]*VAR("scale"))/VAR("scale")
        -- arg[4] = math.round(arg[4]*VAR("scale"))/VAR("scale")
        
        love.graphics.draw(arg[1], arg[2], arg[3], arg[4], arg[5], arg[6], arg[7], arg[8], arg[9])
    end
end

function worldLine(x1, y1, x2, y2)
    love.graphics.line(x1, y1, x2, y2)
end

function worldRectangle(style, x, y, w, h)
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
