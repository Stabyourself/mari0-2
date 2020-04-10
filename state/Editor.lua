local EditorState = require "class.editor.EditorState"
local Selection = require "class.editor.Selection"
local FloatingSelection = require "class.editor.FloatingSelection"
local Editor = class("Editor")

Editor.toolbarOrder = {"Entity", "Paint", "Erase", "Move", "Select", "Wand", "Fill", "Stamp", "Portal"}
Editor.toolbarImg = {}
Editor.toolClasses = {}

for _, toolName in ipairs(Editor.toolbarOrder) do
    Editor.toolClasses[toolName] = require("class.editor.tools." .. toolName)
    table.insert(Editor.toolbarImg, love.graphics.newImage("img/editor/" .. toolName .. ".png"))
end

Editor.checkerboardImg = love.graphics.newImage("img/editor/checkerboard.png")

Editor.scaleMin = 0.1/VAR("scale")
Editor.scaleMax = 3

Editor.selectImg = love.graphics.newImage("img/editor/selection-preview.png")
Editor.selectQuad = {
    love.graphics.newQuad(0, 0, 2, 2, 5, 5),
    love.graphics.newQuad(2, 0, 1, 2, 5, 5),
    love.graphics.newQuad(3, 0, 2, 2, 5, 5),
    love.graphics.newQuad(0, 2, 2, 1, 5, 5),
    love.graphics.newQuad(2, 2, 1, 1, 5, 5),
    love.graphics.newQuad(3, 2, 2, 1, 5, 5),
    love.graphics.newQuad(0, 3, 2, 2, 5, 5),
    love.graphics.newQuad(2, 3, 1, 2, 5, 5),
    love.graphics.newQuad(3, 3, 2, 2, 5, 5),
}

Gui3.boxCache[Editor.selectQuad] = Gui3.makeBoxCache(Editor.selectQuad)

-- load windows
Editor.windowClasses = {
    tiles = require("class.editor.windows.TilesWindow"),
    stamps = require("class.editor.windows.StampsWindow"),
    minimap = require("class.editor.windows.MinimapWindow"),
    mapOptions = require("class.editor.windows.MapOptionsWindow"),
    debug = require("class.editor.windows.DebugWindow"),
}

function Editor:initialize(level)
    self.level = level
end

function Editor:load()
    updateSizes()
    -- The level must be loaded at this point!
    self:setActiveLayer(1)
    self:setActiveTileMap(1)

    self.tools = {}

    for toolName, toolClass in pairs(self.toolClasses) do
        self.tools[string.lower(toolName)] = toolClass:new(self)
    end

    self.canvas = Gui3.Canvas:new(0, 0, SCREENWIDTH, SCREENHEIGHT)
    self.canvas.gui = defaultUI

    self.windows = {}

    -- MENU BAR
    self.menuBar = Gui3.Canvas:new(0, 0, SCREENWIDTH, 14)
    self.menuBar.background = {1, 1, 1, VAR("editor").barAlpha}

    self.canvas:addChild(self.menuBar)



    self.fileDropdown = Gui3.Dropdown:new(0, 0, "file", self.canvas)
    self.fileDropdown.button.color.background = {0, 0, 0, 0}

    self.menuBar:addChild(self.fileDropdown)

    self.fileDropdown.box:addChild(Gui3.TextButton:new(0, 0, "save", false, nil, function(button) self:saveLevel() end))
    self.fileDropdown.box:addChild(Gui3.TextButton:new(0, 10, "load", false, nil, function(button) self:loadLevel("mappacks/smb3/1-1.lua") end))

    self.fileDropdown:autoSize()



    -- WINDOW

    self.newWindowDropdown = Gui3.Dropdown:new(38, 0, "window", self.canvas)
    self.newWindowDropdown.button.color.background = {0, 0, 0, 0}

    self.menuBar:addChild(self.newWindowDropdown)

    self.newWindowDropdown.box:addChild(Gui3.TextButton:new(0, 0, "tiles", false, nil, function(button) self:newWindow(self.windowClasses.tiles, button) end))
    self.newWindowDropdown.box:addChild(Gui3.TextButton:new(0, 10, "stamps", false, nil, function(button) self:newWindow(self.windowClasses.stamps, button) end))
    self.newWindowDropdown.box:addChild(Gui3.TextButton:new(0, 20, "layers", false, nil, function(button) end))
    self.newWindowDropdown.box:addChild(Gui3.TextButton:new(0, 30, "minimap", false, nil, function(button) self:newWindow(self.windowClasses.minimap, button) end))
    self.newWindowDropdown.box:addChild(Gui3.TextButton:new(0, 40, "map options", false, nil, function(button) self:newWindow(self.windowClasses.mapOptions, button) end))
    self.newWindowDropdown.box:addChild(Gui3.TextButton:new(0, 50, "debug", false, nil, function(button) self:newWindow(self.windowClasses.debug, button) end))

    self.newWindowDropdown:autoSize()



    -- VIEW

    local viewDropdown = Gui3.Dropdown:new(92, 0, "view", self.canvas)
    viewDropdown.button.color.background = {0, 0, 0, 0}

    self.menuBar:addChild(viewDropdown)

    self.freeCameraCheckbox = Gui3.Checkbox:new(0, 0, "free camera", 1, function(checkbox) self:toggleFreeCam(checkbox.value) end)
    viewDropdown.box:addChild(self.freeCameraCheckbox)

    self.gridCheckbox = Gui3.Checkbox:new(0, 11, "draw grid", 1, function(checkbox) self:toggleGrid(checkbox.value) end)
    viewDropdown.box:addChild(self.gridCheckbox)

    self.toggleUICheckbox = Gui3.Checkbox:new(0, 22, "hide ui", 1, function(checkbox) self:toggleUI(checkbox.value) end)
    viewDropdown.box:addChild(self.toggleUICheckbox)

    viewDropdown:autoSize()



    -- SCALE BAR
    local w = 50
    local fullw = w+63
    local x = CAMERAWIDTH-113
    self.scaleBar = Gui3.Canvas:new(x, 0, fullw, 14)
    self.menuBar:addChild(self.scaleBar)

    self.scaleSlider = Gui3.Slider:new(self.scaleMin, self.scaleMax, 17, 3, w, false, function(val) self:changeScale(val) end)
    self.scaleSlider.color.bar = {0, 0, 0}

    self.scaleBar:addChild(self.scaleSlider)

    self:changeScale(self.level.camera.scale)

    local minusButton = Gui3.TextButton:new(0, 0, "-", false, 3, function() self:zoom(-1) end)
    minusButton.color.background = {0, 0, 0, 0}
    self.scaleBar:addChild(minusButton)

    local plusButton = Gui3.TextButton:new(w+20, 0, "+", false, 3, function() self:zoom(1) end)
    plusButton.color.background = {0, 0, 0, 0}
    self.scaleBar:addChild(plusButton)

    local oneToOneButton = Gui3.TextButton:new(w+34, 0, "1:1", false, 3, function() self:resetZoom() end)
    oneToOneButton.color.background = {0, 0, 0, 0}
    self.scaleBar:addChild(oneToOneButton)




    -- TOOL BAR
    self.toolbar = Gui3.Canvas:new(0, 14, 14, CAMERAHEIGHT-14)
    self.toolbar.background = {1, 1, 1, VAR("editor").barAlpha}
    self.canvas:addChild(self.toolbar)

    self.toolButtons = {}

    local y = 0
    for i, tool in ipairs(self.toolbarOrder) do
        local button = Gui3.ImageButton:new(0, y, self.toolbarImg[i], false, 2, function(button) self:selectTool(string.lower(tool)) end)
        button.color.background = {0, 0, 0, 0}

        self.toolButtons[string.lower(tool)] = button

        self.toolbar:addChild(button)

        y = y + 14
    end


    self:selectTool("portal")

    self.gridImg = love.graphics.newImage("img/grid.png")
    self.gridImg:setWrap("repeat", "repeat")
    self.gridQuad = love.graphics.newQuad(0, 0, 16, 16, 16, 16)

    self.editorStates = {}
    self.editorState = 1

    self.mapBoundsQuad = love.graphics.newQuad(0, 0, 8, 8, 8, 8)

    self.pastePos = {1, 1}

    self:mapChanged()
    self:toggleGrid(false)
    self:toggleFreeCam(false)
    self:toggleUI(false)
end

function Editor:update(dt)
    prof.push("UI")
    self.canvas:update(dt)
    self.canvas:rootmousemoved(self.level:getMouse())
    prof.pop()

    prof.push("Tool update")
    if self.tool.update then
        self.tool:update(dt)
    end
    prof.pop()

    if self.freeCamera then
        local cameraSpeed = dt*VAR("editor").cameraSpeed*(1/self.level.camera.scale)

        if controls3.cmdDown("editor.right") then
            self.level.camera.x = self.level.camera.x + cameraSpeed
        end

        if controls3.cmdDown("editor.left") then
            self.level.camera.x = self.level.camera.x - cameraSpeed
        end

        if controls3.cmdDown("editor.down") then
            self.level.camera.y = self.level.camera.y + cameraSpeed
        end

        if controls3.cmdDown("editor.up") then
            self.level.camera.y = self.level.camera.y - cameraSpeed
        end
    end

    -- Limit camera position so you can't lose the level
    self.level.camera.x = math.clamp(self.level.camera.x, (self.level:getXStart()-1)*16, self.level:getXEnd()*16)
    self.level.camera.y = math.clamp(self.level.camera.y, (self.level:getYStart()-1)*16, self.level:getYEnd()*16)

    prof.push("Selection")
    if self.selection then
        self.selection:update(dt)
    end

    if self.floatingSelection then
        self.floatingSelection:update(dt)
    end

    for _, window in ipairs(self.windows) do
        if window:isInstanceOf(self.windowClasses.minimap) then
            local x, y = self.level:cameraToWorld(0, 0)

            x = x/16 - self.level:getXStart()
            y = y/16 - self.level:getYStart()

            --x*3, y*3, self.level.camera.w/16+1, self.level.camera.h/16+1
        end
    end
    prof.pop()
end

local stencilXStart
local stencilYStart
local stencilXEnd
local stencilYEnd

local function candyStencil()
    love.graphics.rectangle("fill", stencilXStart, stencilYStart, stencilXEnd-stencilXStart, stencilYEnd-stencilYStart)
end

function Editor:draw()
    self.level.camera:attach()

    local xl, yt = self.level:cameraToWorld(0, 0)
    local xr, yb = self.level:cameraToWorld(self.level.camera.w, self.level.camera.h)

    -- Map bounds graphics
    prof.push("Candy")
    stencilXStart = (self.level:getXStart()-1)*16
    stencilYStart = (self.level:getYStart()-1)*16
    stencilXEnd = (self.level:getXEnd())*16
    stencilYEnd = (self.level:getYEnd())*16

    love.graphics.stencil(candyStencil)

    love.graphics.setStencilTest("notequal", 1)

    self.mapBoundsQuad:setViewport(self.level.camera.x%8, self.level.camera.y%8, xr-xl, yb-yt)
    love.graphics.setColor(0, 0, 0, 0.1)
    love.graphics.draw(debugCandyImg, self.mapBoundsQuad, xl, yt)
    love.graphics.setColor(1, 1, 1)

    love.graphics.setStencilTest()
    prof.pop()

    prof.push("Grid")
    if self.showGrid then
        self.gridQuad:setViewport(
            (xl)%self.level.tileSize,
            (yt)%self.level.tileSize,
            xr-xl+self.level.tileSize,
            yb-yt+self.level.tileSize
        )

        love.graphics.draw(
            self.gridImg,
            self.gridQuad,
            xl,
            yt
        )
    end
    prof.pop()

    prof.push("Selection")
    if self.selection then
        self.selection:draw()
    end

    if self.floatingSelection then
        self.floatingSelection:draw()
    end
    prof.pop()

    prof.push("Tool")
    if self.tool.draw then
        self.tool:draw()
    end
    prof.pop()

    self.level.camera:detach()

    prof.push("UI")

    love.graphics.setColor(1, 1, 1)
    love.graphics.push()
    love.graphics.origin()
    self.canvas:rootDraw()
    love.graphics.pop()

    prof.pop()
end

function Editor:changeScale(val)
    self.level.camera:zoomTo(val)
    self.scaleSlider:setValue(val)
    self:toggleFreeCam(true)
end

function Editor:sliderChanged(val)
    self:changeScale(val)
end

function Editor:toggleFreeCam(on)
    self.freeCameraCheckbox.value = on

    if on then
        self.level.viewports[1].target = nil
        self.freeCamera = true
    else
        self.level.viewports[1].target = game.players[1].actor
        self.freeCamera = false
    end
end

function Editor:toggleGrid(on)
    self.gridCheckbox.value = on
    self.showGrid = on
end

function Editor:toggleUI(hidden)
    if game.uiVisible ~= not hidden then
        game.uiVisible = not hidden
        updateSizes()
        self.toolbar.h = CAMERAHEIGHT-14
        self.toolbar:sizeChanged()
        self.level.camera.h = CAMERAHEIGHT

        self.toggleUICheckbox.value = hidden

        local offset = (ui.height)/2/self.level.camera.scale

        self.level.camera:move(0, offset)
    end
end

function Editor:selectTool(toolName)
    if self.tool and self.tool.unSelect then
        self.tool:unSelect()
    end

    self.tool = self.tools[toolName]

    if self.tool.select then
        self.tool:select()
    end

    for _, toolButton in pairs(self.toolButtons) do
        toolButton.color.background = {0, 0, 0, 0}
        toolButton:updateRender()
    end

    self.toolButtons[toolName].color.background = {0, 0, 0, 0.5}
end

function Editor:newWindow(windowClass, button)
    self.newWindowDropdown:toggle(false)

    table.insert(self.windows, windowClass:new(self))
end

function Editor:selectTile(tile)
    if not tile then
        self:selectTool("erase")
        return
    end

    if self.tool ~= self.tools.paint and self.tool ~= self.tools.fill then
        self:selectTool("paint")
    end

    self.tools.paint.tile = tile

    for _, window in ipairs(self.windows) do
        if window:isInstanceOf(self.windowClasses.tiles) then
            if window.tileGrid then -- not in the category selection
                print(window.tileMap, tile.tileMap)
                if window.tileMap ~= tile.tileMap then -- deselect it
                    window.tileGrid:setSelected(nil)
                else -- select the same tile that was selected
                    window.tileGrid:setSelected(tile.num)
                end
            end
        end
    end
end

function Editor:cmdpressed(cmd)
    if self.tool.cmdpressed and self.tool:cmdpressed(cmd) then
        return true
    end

    if cmd["editor.delete"] then
        if self.selection then
            self.selection:delete()

            self:mapChanged()
        end

        if self.floatingSelection then
            self.floatingSelection = nil
        end

    elseif cmd["editor.undo"] then
        self:undo()

    elseif cmd["editor.redo"] then
        self:redo()

    elseif cmd["editor.copy"] or cmd["editor.cut"] then
        if self.selection then
            self.clipboard, self.pastePos[1], self.pastePos[2] = self.selection:getStampMap()

            if cmd["editor.cut"] then
                self.selection:delete()
            end

        elseif self.floatingSelection then
            self.clipboard, self.pastePos[1], self.pastePos[2] = self.floatingSelection:getStampMap()

            if cmd["editor.cut"] then
                self.floatingSelection = nil
            end
        end

    elseif cmd["editor.paste"] then
        if self.clipboard then
            if self.tool ~= self.tools.select then
                self:selectTool("select")
            end

            if self.floatingSelection then
                self.pastePos = {unpack(self.floatingSelection.pos)}
                self.floatingSelection:unFloat()
            end

            self.floatingSelection = FloatingSelection:new(self, self.clipboard, {self.pastePos[1], self.pastePos[2]})
            self.selection = nil

            self:mapChanged()
        end

    elseif cmd["editor.save"] then
        self:saveLevel()

    elseif cmd["editor.load"] then
        self:loadLevel("mappacks/smb3/1-1.lua")

    elseif cmd["editor.select.clear"] then
        if self.selection then
            self.selection = nil
        end

        if self.floatingSelection then
            self.floatingSelection:reset()
            self.floatingSelection:unFloat()
            self.floatingSelection = nil
        end

    elseif cmd["editor.select.unFloat"] then
        if self.floatingSelection then
            self.floatingSelection:unFloat()
            self.floatingSelection = nil
        end
    end

    for i, _ in pairs(self.toolClasses) do
        if cmd["editor.tool." .. i] then
            self:selectTool(i)
        end
    end
end

function Editor:mousepressed(x, y, button)
    if self.canvas:rootmousepressed(x, y, button) then
        return true
    end

    if self.tool.mousepressed and self.tool:mousepressed(x, y, button) then
        return true
    end
end

function Editor:mousereleased(x, y, button)
    self.canvas:rootmousereleased(x, y, button)

    if self.tool.mousereleased then
        self.tool:mousereleased(x, y, button)
    end

    if self.selection then
        self.selection:mousereleased(x, y, button)
    end

    if self.floatingSelection then
        self.floatingSelection:mousereleased(x, y, button)
    end
end

function Editor:mousemoved(x, y)
    if self.tool.mousemoved then
        self.tool:mousemoved(x, y)
    end
end

function Editor:wheelmoved(x, y)
    -- Zooming
    if controls3.cmdDown("editor.mouseWheelScale") then
        if y ~= 0 then
            self:zoom(y, true)
        end

        return true
    end

    if self.canvas:rootwheelmoved(x, y) then
        return true
    end

    if self.tool.wheelmoved and self.tool:wheelmoved(x, y) then
        return true
    end

    -- Tile scrolling
    if self.tool == self.tools.paint or self.tool == self.tools.fill then
        local tileMap = self.tools.paint.tile.tileMap
        local num = self.tools.paint.tile.num
        local max = #tileMap.tiles

        num = num - y

        if num < 1 then
            num = max
        elseif num > max then
            num = 1
        end

        self:selectTile(tileMap.tiles[num])
    end
end

function Editor:zoom(i, toMouse)
    local zoom

    if i > 0 then -- out
        zoom = 1.1^i
    else -- in!
        zoom = 1/(1.1^-i)
    end


    if self.level.camera.scale*zoom < self.scaleMin then
        zoom = self.scaleMin/self.level.camera.scale
    elseif self.level.camera.scale*zoom > self.scaleMax then
        zoom = self.scaleMax/self.level.camera.scale
    end

    local x, y
    if toMouse then
        x, y = getWorldMouse()
    end

    self.level.camera:zoom(zoom, x, y)
    self.scaleSlider:setValue(self.level.camera.scale)
    self:toggleFreeCam(true)
end

function Editor:resetZoom()
    self:changeScale(1/VAR("scale"))
end

function Editor:resize(w, h)
    self.canvas:resize(w, h)

    self.menuBar:resize(w, self.menuBar.h)

    self.toolbar.h = CAMERAHEIGHT-14
    self.toolbar:sizeChanged()

    local x = CAMERAWIDTH-113
    self.scaleBar.x = x
end


function Editor:saveLevel()
    self.fileDropdown:toggle(false)

    self.level:saveLevel("mappacks/smb3/1-1.lua")
end

function Editor:loadLevel(path)
    self.fileDropdown:toggle(false)

    local mapCode = love.filesystem.read(path)
    local data = sandbox.run(mapCode)
    self.level:loadLevel(data)

    self.activeLayer = self.level.layers[1]
end

function Editor:clearSelection()
    self.selection = nil
end

function Editor:replaceSelection(selection)
    self.selection = Selection:new(self, selection)
end

function Editor:addToSelection(selection)
    if self.selection then
        self.selection:add(selection)
    else
        self.selection = Selection:new(self, selection)
    end
end

function Editor:subtractFromSelection(selection)
    if self.selection then
        self.selection:subtract(selection)
    end
end

function Editor:intersectSelection(selection)
    if self.selection then
        self.selection:intersect(selection)
    end
end

function Editor:mapChanged()
    for i = 1, self.editorState-1 do
        table.remove(self.editorStates, 1)
    end

    prof.push("new editorState")
    table.insert(self.editorStates, 1, EditorState:new(self))
    prof.pop("new editorState")

    self.editorState = 1

    self:updateMinimap()
end

function Editor:undo()
    if #self.editorStates >= 2 and self.editorState < #self.editorStates then
        self.editorState = self.editorState + 1
        self.editorStates[self.editorState]:load()
    end
end

function Editor:redo()
    if self.editorState > 1 then
        self.editorState = self.editorState - 1
        self.editorStates[self.editorState]:load()
    end
end

function Editor:floatSelection()
    if self.selection then
        self.floatingSelection = self.selection:getFloatingSelection()
        self.selection = nil
    end
end

function Editor:unFloatSelection()
    if self.floatingSelection then
        self:mapChanged()

        self.floatingSelection:unFloat()
        self.selection = self.floatingSelection:getSelection()
        self.floatingSelection = nil
    end
end

function Editor:drawSizeHelp(w, h, glue)
    self.level.camera:detach()

    local x, y = self.level:getMouse()
    local s = string.format("%s%s%s", w, glue or "×", h)
    local width = utf8.len(s)*8

    local textX = x+6
    local textY = y

    if textX+width > SCREENWIDTH then
        textX = x - width
    end

    if textY+8 > SCREENHEIGHT then
        textY = y-8
    end

    love.graphics.print(s, textX, textY)

    self.level.camera:attach()
end

function Editor:setActiveLayer(layerNo)
    self.activeLayer = self.level.layers[layerNo]
end

function Editor:setActiveTileMap(tileMap)
    self.tileMap = tileMap
end

function Editor:setActiveStampMap(stampMap)
    self.tools.stamp.stampMap = stampMap
end

function Editor:pipette()
    local coordX, coordY = self.level:mouseToCoordinate()
    local layer = self.activeLayer

    if layer:inMap(coordX, coordY) then
        local tile = layer:getTile(coordX, coordY)

        self:selectTile(tile)
    end
end

function Editor:updateMinimap()
    prof.push("updateMinimap")
    if VAR("minimapType") == "realistic" then
        local minimapScale = 8/3*VAR("scale")

        local yStart = self.level:getYStart()
        local yEnd = self.level:getYEnd()
        local xStart = self.level:getXStart()
        local xEnd = self.level:getXEnd()

        local width = xEnd - xStart + 1
        local height = yEnd - yStart + 1

        if not self.minimapCanvas then
            self.minimapCanvas = love.graphics.newCanvas(width*minimapScale, height*minimapScale)
        end

        love.graphics.setCanvas(self.minimapCanvas)
        love.graphics.clear(self.level.backgroundColor)
        love.graphics.push()
        love.graphics.origin()
        love.graphics.scale(minimapScale/16)

        -- set tilemaps' filter
        for _, tileMap in ipairs(self.level.tileMaps) do
            tileMap:setFilter("linear", "linear")
        end

        for x = xStart, xEnd do
            for y = yStart, yEnd do
                local cell = self.level.layers[1]:getCell(x, y)

                cell:drawFrame(1)
            end
        end

        -- set it back!
        for _, tileMap in ipairs(self.level.tileMaps) do
            tileMap:setFilter("nearest", "nearest")
        end

        love.graphics.pop()
        love.graphics.setCanvas()

        self.minimapImg = self.minimapCanvas
        self.minimapScale = 1

        -- Update existing minimap windows
        for _, window in ipairs(self.windows) do
            if window:isInstanceOf(self.windowClasses.minimap) then
                window.minimapDraw.w = self.minimapCanvas:getWidth()
                window.minimapDraw.h = self.minimapCanvas:getHeight()
                window.minimapDraw:sizeChanged()
            end
        end
        prof.pop("updateMinimap")
    elseif VAR("minimapType") == "blocky" then
        prof.push("updateMinimap")
        local yStart = self.level:getYStart()
        local yEnd = self.level:getYEnd()
        local xStart = self.level:getXStart()
        local xEnd = self.level:getXEnd()

        local width = xEnd - xStart + 1
        local height = yEnd - yStart + 1

        if not self.minimapImgData then
            self.minimapImgData = love.image.newImageData(width, height)
        end

        self.minimapImgData:mapPixel(function (x, y)
            local tileX = xStart + x
            local tileY = yStart + y

            local tile = self.level:getTile(tileX, tileY)

            if tile then
                if VAR("blockyMinimapSource") == "average" then
                    return unpack(tile:getAverageColor())
                elseif VAR("blockyMinimapSource") == "prominent" then
                    return unpack(tile:getProminentColor())
                end
            else
                return unpack(self.level.backgroundColor)
            end
        end)

        self.minimapImg = love.graphics.newImage(self.minimapImgData)
        self.minimapScale = VAR("scale")*3

        -- Update existing minimap windows
        for _, window in ipairs(self.windows) do
            if window:isInstanceOf(self.windowClasses.minimap) then
                window.minimapDraw.w = width
                window.minimapDraw.h = height
                window.minimapDraw:sizeChanged()
            end
        end
        prof.pop("updateMinimap")
    end
end

function Editor:drawMinimap()
    love.graphics.draw(self.minimapImg, 0, 0, 0, self.minimapScale/VAR("scale"), self.minimapScale/VAR("scale"))

    -- local lx, ty = self.level:cameraToWorld(0, 0)
    -- local rx, by = self.level:cameraToWorld(self.level.camera.w, self.level.camera.h)

    -- love.graphics.push()
    -- love.graphics.scale(3, 3)
    -- love.graphics.rectangle("line", lx/16-.5, ty/16-.5, (rx-lx)/16+1, (by-ty+1)/16+1)
    -- love.graphics.pop()
end

function Editor:clickMinimap(x, y, button)
    x = x/(8/3)
    y = y/(8/3)

    x, y = self.level:coordinateToWorld(x, y)

    if button == 1 then
        self.level.camera:lookAt(x, y)
        self:toggleFreeCam(true)
    elseif button == 2 then
        game.players[1].actor.x = x - game.players[1].actor.width/2
        game.players[1].actor.y = y - game.players[1].actor.height
    end
end

return Editor
