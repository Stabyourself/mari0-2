Editor = class("Editor")

Editor.toolbarOrder = {"entity", "paint", "erase", "move", "select", "wand", "fill", "stamp"}
Editor.toolbarImg = {}

for _, toolName in ipairs(Editor.toolbarOrder) do
    table.insert(Editor.toolbarImg, love.graphics.newImage("img/editor/" .. toolName .. ".png"))
end

Editor.checkerboardImg = love.graphics.newImage("img/editor/checkerboard.png")

Editor.toolClasses = {
    entity = require("class.editor.tools.Entity"),
    paint = require("class.editor.tools.Paint"),
    select = require("class.editor.tools.Select"),
    move = require("class.editor.tools.Move"),
    fill = require("class.editor.tools.Fill"),
    stamp = require("class.editor.tools.Stamp"),
    wand = require("class.editor.tools.Wand"),
    erase = require("class.editor.tools.Erase"),
}

Editor.scaleMin = 0.1/VAR("scale")
Editor.scaleMax = 1

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
}

function Editor:initialize(level)
    self.level = level
end

function Editor:load()
    -- The level must be loaded at this point!
    self:setActiveLayer(1)
    self:setActiveTileMap(1)

    self.tools = {}
    
    for toolName, toolClass in pairs(self.toolClasses) do
        self.tools[toolName] = toolClass:new(self)
    end
    
    self.canvas = Gui3.Canvas:new(0, 0, SCREENWIDTH, SCREENHEIGHT)
    self.canvas.gui = defaultUI
    
    self.windows = {}
    
    -- MENU BAR
    self.menuBar = Gui3.Canvas:new(0, 0, SCREENWIDTH, 14)
    self.menuBar.background = {1, 1, 1}
    
    self.canvas:addChild(self.menuBar)


    
    self.fileDropdown = Gui3.Dropdown:new(0, 0, "file")
    
    self.menuBar:addChild(self.fileDropdown)
    
    self.fileDropdown.box:addChild(Gui3.Button:new(0, 0, "save", false, 1, function(button) self:saveLevel() end))
    self.fileDropdown.box:addChild(Gui3.Button:new(0, 10, "load", false, 1, function(button) self:loadLevel("1-1.json") end))
    
    self.fileDropdown:autoSize()
    
    
    
    -- WINDOW
    
    self.newWindowDropdown = Gui3.Dropdown:new(38, 0, "window")
    
    self.menuBar:addChild(self.newWindowDropdown)
    
    self.newWindowDropdown.box:addChild(Gui3.Button:new(0, 0, "tiles", false, 1, function(button) self:newWindow(self.windowClasses.tiles, button) end))
    self.newWindowDropdown.box:addChild(Gui3.Button:new(0, 10, "stamps", false, 1, function(button) self:newWindow(self.windowClasses.stamps, button) end))
    self.newWindowDropdown.box:addChild(Gui3.Button:new(0, 20, "layers", false, 1, function(button) end))
    self.newWindowDropdown.box:addChild(Gui3.Button:new(0, 30, "minimap", false, 1, function(button) self:newWindow(self.windowClasses.minimap, button) end))
    self.newWindowDropdown.box:addChild(Gui3.Button:new(0, 40, "map options", false, 1, function(button) end))
    
    self.newWindowDropdown:autoSize()
    
    
    
    -- VIEW
    
    local viewDropdown = Gui3.Dropdown:new(92, 0, "view")
    
    self.menuBar:addChild(viewDropdown)
    
    viewDropdown.box:addChild(Gui3.Checkbox:new(0, 0, "free camera", 1, function(checkbox) self:toggleFreeCam(checkbox.value) end))
    viewDropdown.box:addChild(Gui3.Checkbox:new(0, 11, "draw grid", 1, function(checkbox) self:toggleGrid(checkbox.value) end))
    viewDropdown.box:addChild(Gui3.Checkbox:new(0, 22, "hide ui", 1, function(checkbox) self:toggleUI(checkbox.value) end))
    
    viewDropdown:autoSize()
    
    
    
    -- SCALE BAR
    local w = 50
    local fullw = w+63
    local x = CAMERAWIDTH-fullw
    self.scaleBar = Gui3.Canvas:new(x, 0, fullw, 14)
    self.menuBar:addChild(self.scaleBar)
    
    self.scaleSlider = Gui3.Slider:new(self.scaleMin, self.scaleMax, 17, 3, w, false, function(val) self:changeScale(val) end)
    self.scaleSlider.color.bar = {0, 0, 0}
    
    self.scaleBar:addChild(self.scaleSlider)
    
    self:updateScaleSlider()
    
    self.scaleBar:addChild(Gui3.Button:new(0, 0, "-", false, 3, function() self:zoom(-1) end))
    self.scaleBar:addChild(Gui3.Button:new(w+20, 0, "+", false, 3, function() self:zoom(1) end))
    
    self.scaleBar:addChild(Gui3.Button:new(w+34, 0, "1:1", false, 3, function() self:resetZoom() end))
    
    
    
    
    -- TOOL BAR
    self.toolbar = Gui3.Canvas:new(0, 14, 14, CAMERAHEIGHT-14)
    self.toolbar.background = {255, 255, 255}
    self.canvas:addChild(self.toolbar)
    
    self.toolButtons = {}
    
    local y = 0
    for i, tool in ipairs(self.toolbarOrder) do
        local button = Gui3.Button:new(0, y, self.toolbarImg[i], false, 2, function(button) self:selectTool(tool) end)
        
        self.toolButtons[tool] = button
        
        button.children[1].color = {0, 0, 0, 1}
        self.toolbar:addChild(button)
        
        y = y + 14
    end
    
    
    
    
    self:selectTool("paint")
    
    self.gridImg = love.graphics.newImage("img/grid.png")
    self.gridImg:setWrap("repeat", "repeat")
    self.gridQuad = love.graphics.newQuad(0, 0, 16, 16, 16, 16)

    self.editorStates = {}
    self.editorState = 1
    self:saveState()
    
    self.mapBoundsQuad = love.graphics.newQuad(0, 0, 8, 8, 8, 8)

    self.pastePos = {1, 1}

    self:updateMinimap()
    
    self:toggleGrid(false)
    self:toggleFreeCam(false)
end

function Editor:update(dt)
    prof.push("Editor")
    prof.push("UI")
    self.canvas:update(dt)
    prof.pop()
    
    prof.push("Tool update")
    if self.tool.update then
        self.tool:update(dt)
    end
    prof.pop()
    
    if self.freeCamera then
        local cameraSpeed = dt*VAR("editor").cameraSpeed--*(1/self.level.camera.scale)
        
        if cmdDown("right") then
            self.level.camera.x = self.level.camera.x + cameraSpeed
        end
        
        if cmdDown("left") then
            self.level.camera.x = self.level.camera.x - cameraSpeed
        end
        
        if cmdDown("down") then
            self.level.camera.y = self.level.camera.y + cameraSpeed
        end
        
        if cmdDown("up") then
            self.level.camera.y = self.level.camera.y - cameraSpeed
        end
    end
    
    -- Limit camera position so you can't lose the level
    self.level.camera.x = math.clamp(self.level.camera.x, self.level:getXStart()*16, self.level:getXEnd()*16)
    self.level.camera.y = math.clamp(self.level.camera.y, self.level:getYStart()*16, self.level:getYEnd()*16)
    
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
            
            window:updateBorder(x*3, y*3, CAMERAWIDTH/16+1, CAMERAHEIGHT/16+1)
        end
    end
    prof.pop()
    prof.pop()
end

function Editor:draw()
    prof.push("Editor")
    self.level.camera:attach()
    
    local xl, yt = self.level:cameraToWorld(0, 0)
    local xr, yb = self.level:cameraToWorld(CAMERAWIDTH, CAMERAHEIGHT)
    
    -- Map bounds graphics
    prof.push("Candy")
    love.graphics.stencil(function()
        local xStart = (self.level:getXStart()-1)*16
        local yStart = (self.level:getYStart()-1)*16

        local xEnd = (self.level:getXEnd())*16
        local yEnd = (self.level:getYEnd())*16

        love.graphics.rectangle("fill", xStart, yStart, xEnd-xStart, yEnd-yStart)
    end)
    love.graphics.setStencilTest("notequal", 1)
    
    self.mapBoundsQuad:setViewport(0, 0, xr-xl, yb-yt)
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
    self.canvas:draw()
    prof.pop()
    prof.pop()
end

function Editor:changeScale(val)
    self.level.camera:zoomTo(val)
end

function Editor:updateScaleSlider()
    self.scaleSlider:setValue(self.level.camera.scale)
end

function Editor:toggleFreeCam(on)
    if on then
        self.level.camera.target = nil
        self.freeCamera = true
    else
        self.level.camera.target = self.level.marios[1]
        self.freeCamera = false
    end
end

function Editor:toggleGrid(on)
    self.showGrid = on
end

function Editor:toggleUI(on)
    if game.uiVisible ~= not on then
        game.uiVisible = not on
        updateSizes()
        self.toolbar.h = CAMERAHEIGHT-14
        self.level.camera.h = CAMERAHEIGHT
        
        local offset = (VAR("uiLineHeight")+VAR("uiHeight"))/2/self.level.camera.scale
        
        if on then
            self.level.camera:move(0, offset)
        else
            self.level.camera:move(0, -offset)
        end
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
        toolButton.color.background = {1, 1, 1}
    end
    
    self.toolButtons[toolName].color.background = {0.75, 0.75, 0.75}
end

function Editor:newWindow(windowClass, button)
    self.newWindowDropdown:toggle(false)

    table.insert(self.windows, windowClass:new(self))
end

function Editor:selectTile(tile)
    if self.tool ~= self.tools.paint and self.tool ~= self.tools.fill then
        self:selectTool("paint")
    end
    
    self.tools.paint.tile = tile

    for _, window in ipairs(self.windows) do
        if window:isInstanceOf(self.windowClasses.tiles) then
            if window.tileMap ~= tile.tileMap then -- deselect it
                window.tileListTileGrid.selected = false
            else -- select the same tile that was selected
                window.tileListTileGrid.selected = tile.num
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
            
            self:saveState()
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
            self:selectTool("select")

            if self.floatingSelection then
                self.pastePos = {unpack(self.floatingSelection.pos)}
                self.floatingSelection:unFloat()
            end

            self.floatingSelection = FloatingSelection:new(self, self.clipboard, {self.pastePos[1], self.pastePos[2]})
            self.selection = nil

            self:saveState()
        end
        
    elseif cmd["editor.save"] then
        self:saveLevel()
        
    elseif cmd["editor.load"] then
        self:loadLevel("1-1.json")
        
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
    if self.canvas:mousepressed(x, y, button) then -- don't do tool stuff if the click was on a GUI element
        return true
    end
    
    if self.tool.mousepressed and self.tool:mousepressed(x, y, button) then
        return true
    end
end

function Editor:mousereleased(x, y, button)
    self.canvas:mousereleased(x, y, button)
    
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
        self.tool:mousemoved(x, y, button)
    end
end

function Editor:wheelmoved(x, y)
    if self.canvas:wheelmoved(x, y) then
        return true
    end
    
    if self.tool.wheelmoved and self.tool:wheelmoved(x, y) then
        return true
    end

    if y ~= 0 then
        self:zoom(y, true)
    end
end

function Editor:zoom(i, toMouse)
    local zoom
         
    if i > 0 then -- out
        zoom = 1.1^i
    else
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
    
    self:updateScaleSlider()
end
    
function Editor:resetZoom()
    self.level.camera:zoomTo(1/VAR("scale"))
    self:updateScaleSlider()
end

function Editor:resize(w, h)
    self.canvas:resize(w, h)
    
    self.menuBar:resize(w, self.menuBar.h)
    
    self.toolbar.h = CAMERAHEIGHT-14
    
    local w = 50
    local fullw = w+63
    local x = CAMERAWIDTH-fullw
    self.scaleBar.x = x
end

function Editor:saveLevel()
    self.fileDropdown:toggle(false)
    
    self.level:saveLevel("1-1.json")
end

function Editor:loadLevel(path)
    self.fileDropdown:toggle(false)
    
    local data = JSON:decode(love.filesystem.read(path))
    self.level:loadLevel(data)

    self.activeLayer = self.level.layers[1]

    self:updateMinimap()
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

function Editor:saveState()
    for i = 1, self.editorState-1 do
        table.remove(self.editorStates, 1)
    end
    
    table.insert(self.editorStates, 1, EditorState:new(self))

    self.editorState = 1
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
        self:saveState()
        
        self.floatingSelection:unFloat()
        self.selection = self.floatingSelection:getSelection()
        self.floatingSelection = nil
    end
end

function Editor:drawSizeHelp(w, h)
    self.level.camera:detach()

    local x, y = self.level:getMouse()
    local s = string.format("%s×%s", w, h)
    local width = utf8.len(s)*8

    local textX = x+6
    local textY = y

    if textX+width > SCREENWIDTH then
        textX = x - width
    end

    if textY+8 > SCREENHEIGHT then
        textY = y-8
    end

    love.graphics.print(s, textX, textY, 0, 1, r)

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
        
        if tile then
            self.tools.paint.tile = tile

            if self.tool ~= self.tools["fill"] then
                self:selectTool("paint")
            end
        else
            self:selectTool("erase")
        end
    end
end

function Editor:updateMinimap()
    local t = love.timer.getTime()
    
    local yStart = self.level:getYStart()
    local yEnd = self.level:getYEnd()
    local xStart = self.level:getXStart()
    local xEnd = self.level:getXEnd()

    local width = xEnd - xStart + 1
    local height = yEnd - yStart + 1

    self.minimapImgData = love.image.newImageData(width, height)

    for y = 1, height do
        for x = 1, width do
            local tileX = xStart + x - 1
            local tileY = yStart + y - 1

            local tile = self.level:getTile(tileX, tileY)

            if tile then
                self.minimapImgData:setPixel(x-1, y-1, unpack(tile:getAverageColor()))
            else
                self.minimapImgData:setPixel(x-1, y-1, unpack(self.level.backgroundColor))
            end
        end
    end

    self.minimapImg = love.graphics.newImage(self.minimapImgData)

    -- update all minimap windows

    for _, window in ipairs(self.windows) do
        if window:isInstanceOf(self.windowClasses.minimap) then
            window:updateImg(self.minimapImg)
        end
    end
end

function Editor:drawMinimap()
    love.graphics.draw(self.minimapImg)
end
