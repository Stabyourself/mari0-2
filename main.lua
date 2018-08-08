--Mari0 2 - MIT License.
-- require "errorhandler"
require "loop"

local Game, Editor, replay3

function love.load()
    require "util"

    love.window.setMode(400*VAR("scale"), 224*VAR("scale"), {
        vsync = VAR("vsync"),
        resizable = true,
        msaa = msaa,
        minwidth = 243*VAR("scale"),
        minheight = 165*VAR("scale"),
    })

    love.window.setTitle("Mari0 2")
    love.window.setIcon(love.image.newImageData("img/icon.png"))

    love.graphics.setDefaultFilter("nearest", "nearest")
    -- Libs
    utf8 = require "utf8"
    class = require "lib.middleclass"
    sandbox = require "lib.sandbox"
    Easing = require "lib.Easing"
    paletteShader = require "lib.paletteShader"
    if VAR("debug").jprof then
        PROF_CAPTURE = true
    end
    prof = require "lib.jprof.jprof"
    prof.enabled(false)

    -- Self written libs
    Color3 = require "lib.Color3"
    -- Font3 = require "lib.Font3"
    Physics3 = require "lib.Physics3"
    Gui3 = require "lib.Gui3"
    FrameDebug3 = require "lib.FrameDebug3"
    controls3 = require "lib.controls3"
    controls3.setCmdTable(require "controls")

    -- Loaders
    SETTINGS = require "settingsLoader"
    require "actorTemplateLoader"
    require "componentLoader"

    -- Misc
    require "cheats"
    replay3 = require "lib.replay3"
    replay3.init()

    -- States
    Game = require "state.Game"
    Editor = require "state.Editor"

    fontOutlined = love.graphics.newImageFont("img/font-outlined.png",
        " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789$.,:;!?_-<>=+*\\/'%∩⇔→⇒◔×")
    love.graphics.setFont(fontOutlined)

    debugCandyImg = love.graphics.newImage("img/debug-candy.png")
    debugCandyImg:setWrap("repeat")

    if love.math.random() > 0.99 then
        funkyImg = love.graphics.newImage("img/funky.png")
    end

    defaultUI = Gui3:new("img/gui/default")

    local GameStateManager3 = require "lib.GameStateManager3"
    gameStateManager = GameStateManager3:new()

    love.resize(400*VAR("scale"), 224*VAR("scale"))

    -- Alright let's go do the stuff
    game = Game:new("smb3", 1)

    gameStateManager:loadState(game)
    -- gameStateManager:addState(Editor:new(game.level))

    prof.enabled(true)
end

function love.update(dt)
    replay3.update(dt)
    if VAR("debug").lovebird then
        require("lib/lovebird").update()
    end

    dt = math.min(1/30, dt) -- Min 30 FPS

    dt = FrameDebug3.update(dt)

    if not dt then
        return
    end

    gameStateManager:event("update", dt)
end

local function setColorBasedOn(key)
    if controls3.cmdDown(key) then
        love.graphics.setColor(1, 1, 1)
    else
        love.graphics.setColor(0.2, 0.2, 0.2)
    end
end

function love.draw()
    love.graphics.push()
    love.graphics.scale(VAR("scale"), VAR("scale"))

    gameStateManager:event("draw")

    -- For the stream
    if VAR("debug").input then
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

    love.graphics.pop()

    if funkyImg then
        love.graphics.draw(funkyImg, love.graphics.getWidth(), 0, 0, 1, 1, 340)
    end
end

function love.keypressed(key)
    boop = true
    local cmds, any = controls3.getCmdsForKey(key)

    if cmds["quit"] then
        love.event.quit()
        return
    end

    -- debug
    if cmds["debug.pausePlay"] then
        FrameDebug3.pausePlay()
    end

    if cmds["debug.frameAdvance"] then
        FrameDebug3.frameAdvance()
    end

    if any then
        gameStateManager:event("cmdpressed", cmds)
    end

    gameStateManager:event("keypressed", key)
end

function getWorldMouse()
    return love.mouse.getX()/VAR("scale"), love.mouse.getY()/VAR("scale")
end

function love.mousepressed(x, y, button)
    x, y = x/VAR("scale"), y/VAR("scale")

    gameStateManager:event("mousepressed", x, y, button)
end

function love.mousereleased(x, y, button)
    x, y = x/VAR("scale"), y/VAR("scale")

    gameStateManager:event("mousereleased", x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    dx, dy = dx/VAR("scale"), dy/VAR("scale")

    gameStateManager:event("mousemoved", dx, dy)
end

function love.resize(w, h)
    SCREENWIDTH = w/VAR("scale")
    SCREENHEIGHT = h/VAR("scale")

    updateSizes()

    gameStateManager:event("resize", SCREENWIDTH, SCREENHEIGHT)
end

function love.quit()
    if PROF_CAPTURE then
        prof.write("lastrun.prof")
    end

    replay3.save()
end

function updateSizes()
    CAMERAWIDTH = SCREENWIDTH
    CAMERAHEIGHT = SCREENHEIGHT

    -- Remove the UI's height if present
    if (not game or game.uiVisible) and ui then
        CAMERAHEIGHT = CAMERAHEIGHT-ui.height
    end

    RIGHTSCROLLBORDER = VAR("cameraScrollRightBorder")
    LEFTSCROLLBORDER = VAR("cameraScrollLeftBorder")

    DOWNSCROLLBORDER = VAR("cameraScrollDownBorder")
    UPSCROLLBORDER = VAR("cameraScrollUpBorder")

    debugCandyQuad = love.graphics.newQuad(0, 0, SCREENWIDTH, SCREENHEIGHT, 8, 8)
end

function love.wheelmoved(x, y)
    gameStateManager:event("wheelmoved", x, y)
end

function updateGroup(group, dt)
	for i = #group, 1, -1 do
		if group[i]:update(dt) or group[i].deleteMe then
			table.remove(group, i)
		end
	end
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

function worldArrow(x, y, xDir, yDir)
    local scale = math.sqrt(xDir^2+yDir^2)/8
    local angle = math.atan2(yDir, xDir)
    local arrowTipScale = 0.2

    --body
    local x2, y2 = x+math.cos(angle)*scale, y+math.sin(angle)*scale

    love.graphics.line(x, y, x2, y2)

    --tipleft (m'lady)
    local x3 = x2+math.cos(angle-math.pi*0.75)*scale*arrowTipScale
    local y3 = y2+math.sin(angle-math.pi*0.75)*scale*arrowTipScale
    love.graphics.line(x2, y2, x3, y3)

    --tipright
    local x4 = x2+math.cos(angle+math.pi*0.75)*scale*arrowTipScale
    local y4 = y2+math.sin(angle+math.pi*0.75)*scale*arrowTipScale
    love.graphics.line(x2, y2, x4, y4)
end
