Editor = class("Editor")

Editor.toolbarOrder = {"entity", "paint", "erase", "move", "select", "wand", "fill", "stamp"}
Editor.toolbarImg = {}

for _, v in ipairs(Editor.toolbarOrder) do
    table.insert(Editor.toolbarImg, love.graphics.newImage("img/editor/" .. v .. ".png"))
end

local checkerboardImg = love.graphics.newImage("img/editor/checkerboard.png")

Editor.toolClasses = {
    entity = require("class.editortools.entity"),
    paint = require("class.editortools.Paint"),
    select = require("class.editortools.Select"),
    move = require("class.editortools.Move"),
    fill = require("class.editortools.Fill"),
    stamp = require("class.editortools.Stamp"),
    wand = require("class.editortools.Wand"),
    erase = require("class.editortools.Erase"),
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

function Editor:initialize(level)
    self.level = level
end

function Editor:load()
    self.tileMap = self.level.tileMaps["smb3-grass"]
    
    self.tools = {}
    
    for i, v in pairs(self.toolClasses) do
        self.tools[i] = v:new(self)
    end
    
    self.canvas = Gui3.Canvas:new(0, 0, SCREENWIDTH, SCREENHEIGHT)
    self.canvas.gui = defaultUI
    
    self.windows = {}
    
    -- MENU BAR
    self.menuBar = Gui3.Canvas:new(0, 0, SCREENWIDTH, 14)
    self.menuBar.background = {1, 1, 1}
    self.menuBar.noClip = true
    
    self.canvas:addChild(self.menuBar)


    
    self.fileDropdown = Gui3.Dropdown:new(0, 0, "file")
    
    self.menuBar:addChild(self.fileDropdown)
    
    self.fileDropdown.box:addChild(Gui3.Button:new(0, 0, "save", false, 1, function(button) self:saveMap() end))
    self.fileDropdown.box:addChild(Gui3.Button:new(0, 10, "load", false, 1, function(button) self:loadMap("test.json") end))
    
    self.fileDropdown:autoSize()
    
    
    
    -- WINDOW
    
    self.newWindowDropdown = Gui3.Dropdown:new(38, 0, "window")
    
    self.menuBar:addChild(self.newWindowDropdown)
    
    self.newWindowDropdown.box:addChild(Gui3.Button:new(0, 0, "tiles", false, 1, function(button) self:newWindow("tiles", button) end))
    self.newWindowDropdown.box:addChild(Gui3.Button:new(0, 10, "stamps", false, 1, function(button) self:newWindow("stamps", button) end))
    self.newWindowDropdown.box:addChild(Gui3.Button:new(0, 20, "minimap", false, 1, function(button) self:newWindow("minimap", button) end))
    self.newWindowDropdown.box:addChild(Gui3.Button:new(0, 30, "map options", false, 1, function(button) self:newWindow("mapOptions", button) end))
    self.newWindowDropdown.box:addChild(Gui3.Button:new(0, 40, "test", false, 1, function(button) self:newWindow("test", button) end))
    
    self.newWindowDropdown:autoSize()
    
    
    
    -- VIEW
    
    local viewDropdown = Gui3.Dropdown:new(92, 0, "view")
    
    self.menuBar:addChild(viewDropdown)
    
    viewDropdown.box:addChild(Gui3.Checkbox:new(0, 0, "free camera", 1, function(checkbox) self:toggleFreeCam(checkbox.value) end, true))
    viewDropdown.box:addChild(Gui3.Checkbox:new(0, 11, "draw grid", 1, function(checkbox) self:toggleGrid(checkbox.value) end))
    viewDropdown.box:addChild(Gui3.Checkbox:new(0, 22, "hide ui", 1, function(checkbox) self:toggleUI(checkbox.value) end))
    
    viewDropdown:autoSize()
    
    
    
    -- SCALE BAR
    local w = 50
    local fullw = w+52
    local x = CAMERAWIDTH-fullw
    self.scaleBar = Gui3.Canvas:new(x, 0, fullw, 14)
    self.menuBar:addChild(self.scaleBar)
    
    self.scaleSlider = Gui3.Slider:new(self.scaleMin, self.scaleMax, 10, 3, w, false, function(val) self:changeScale(val) end)
    self.scaleSlider.color.bar = {0, 0, 0}
    
    self.scaleBar:addChild(self.scaleSlider)
    
    self:updateScaleSlider()
    
    self.scaleBar:addChild(Gui3.Button:new(0, 2, "-", false, 1, function() self:zoom(-1) end))
    self.scaleBar:addChild(Gui3.Button:new(w+10, 2, "+", false, 1, function() self:zoom(1) end))
    
    self.scaleBar:addChild(Gui3.Button:new(w+24, 2, "1:1", false, 1, function() self:resetZoom() end))
    
    
    
    
    -- TOOL BAR
    self.toolbar = Gui3.Canvas:new(0, 14, 14, CAMERAHEIGHT-14)
    self.toolbar.background = {255, 255, 255}
    self.canvas:addChild(self.toolbar)
    
    self.toolButtons = {}
    
    local y = 1
    for i, v in ipairs(self.toolbarOrder) do
        local button = Gui3.Button:new(1, y, self.toolbarImg[i], false, 1, function(button) self:selectTool(v) end)
        
        self.toolButtons[v] = button
        
        button.color.img = {0, 0, 0}
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
    
    self.mapBoundsQuads = {}
    for i = 1, 4 do
        self.mapBoundsQuads[i] = love.graphics.newQuad(0, 0, 8, 8, 8, 8)
    end

    self.pastePos = {1, 1}
    
    self:toggleGrid(false)
    self:toggleFreeCam(true)
end

function Editor:update(dt)
    self.canvas:update(dt)
    
    if self.tool.update then
        self.tool:update(dt)
    end
    
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
    self.level.camera.x = math.clamp(self.level.camera.x, 0, self.level.width*16)
    self.level.camera.y = math.clamp(self.level.camera.y, 0, self.level.height*16)
    
    if self.selection then
        self.selection:update(dt)
    end
    
    if self.floatingSelection then
        self.floatingSelection:update(dt)
    end
end

function Editor:draw()
    self.level.camera:attach()
    
    local xl, yt = self.level:cameraToWorld(0, 0)
    local xr, yb = self.level:cameraToWorld(CAMERAWIDTH, CAMERAHEIGHT)
    
    -- Map bounds graphics
    love.graphics.stencil(function()
        love.graphics.rectangle("fill", 0, 0, self.level.width*16, self.level.height*16)
    end)
    love.graphics.setStencilTest("notequal", 1)
    
    self.mapBoundsQuads[1]:setViewport(0, 0, xr-xl, yb-yt)
    love.graphics.setColor(0, 0, 0, 0.1)
    love.graphics.draw(debugCandyImg, self.mapBoundsQuads[1], xl, yt)
    love.graphics.setColor(1, 1, 1)
    
    love.graphics.setStencilTest()
        
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
    
    if self.selection then
        self.selection:draw()
    end
    
    
    if self.floatingSelection then
        self.floatingSelection:draw()
    end
    
    if self.tool.draw then
        self.tool:draw()
    end
    
    self.level.camera:detach()
    
    self.canvas:draw()
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
    
    for _, v in pairs(self.toolButtons) do
        v.color.background = {1, 1, 1}
    end
    
    self.toolButtons[toolName].color.background = {0.75, 0.75, 0.75}
end

function Editor:newWindow(type, button)
    local y = 14
    local x = 14
    
    self.newWindowDropdown:toggle(false)

    if type == "test" then
        local testWindow = Gui3.Box:new(x, y, 100, 100)
        testWindow.draggable = true
        testWindow.resizeable = true
        testWindow.closeable = true
        testWindow.scrollable = {true, true}
        testWindow.title = "Why did you press"
        testWindow.background = self.level.backgroundColor
        
        self.canvas:addChild(testWindow)
        
        
        for y = 0, 80, 20 do
            local text = Gui3.Text:new("Important", 0, y)
            testWindow:addChild(text)
            
            local slider = Gui3.Slider:new(0, 100, 0, y+9, 100, true)
            
            testWindow:addChild(slider)
        end
        
        
        local testWindow2 = Gui3.Box:new(10, 30, 100, 100)
        testWindow2.draggable = true
        testWindow2.resizeable = true
        testWindow2.closeable = true
        testWindow2.scrollable = {true, true}
        testWindow2.title = ":<"
        testWindow2.background = self.level.backgroundColor
        
        testWindow:addChild(testWindow2)
        
        testWindow2:addChild(Gui3.Button:new(5, 5, "don't hurt me!", true))
        
    elseif type == "tiles" then
        local tileListWindow = Gui3.Box:new(x, y, 8*17+15, 200)
        tileListWindow.draggable = true
        tileListWindow.resizeable = true
        tileListWindow.closeable = true
        tileListWindow.scrollable = {true, true}
        tileListWindow.title = "tiles"
        tileListWindow.background = checkerboardImg
        
        self.canvas:addChild(tileListWindow)
        
        
        -- local backButton = Gui3.Button:new(0, 0, "< back", true, 1, function() print("woah") end)
        -- tileListWindow:addChild(backButton)
        
        
        local tileListButtonGrid = Gui3.ButtonGrid:new(1, 1, self.tileMap.img, self.tileMap.quad, 
            function(buttonGrid, i) 
                buttonGrid.selected = i
                self:selectTile(i)
            end
        )
        tileListWindow:addChild(tileListButtonGrid)
        
    end
end

function Editor:selectTile(i)
    if self.tool ~= self.tools.paint and self.tool ~= self.tools.fill then
        self:selectTool("paint")
    end
    
    self.tools.paint.tile = self.tileMap.tiles[i]
end

function Editor:cmdpressed(cmd)
    if self.tool.cmdpressed and self.tool:cmdpressed(cmd) then
        return true
    end
    
    if cmd["editor.delete"] then
        if self.selection then
            if self.selection:delete() then
                self:clearSelection()
            end
            
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
        self:saveMap()
        
    elseif cmd["editor.load"] then
        self:loadMap("test.json")
        
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
    local fullw = w+52
    local x = CAMERAWIDTH-fullw
    self.scaleBar.x = x
end

function Editor:saveMap()
    self.fileDropdown:toggle(false)
    
    self.level:saveMap("test.json")
end

function Editor:loadMap(path)
    self.fileDropdown:toggle(false)
    
    local data = JSON:decode(love.filesystem.read(path))
    self.level:loadMap(data)
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

function Editor:expandMapTo(x, y)
    local moveMapX, moveMapY, moveWorldX, moveWorldY = self.level:expandMapTo(x, y)
    
    if self.selection then
        for _, v in ipairs(self.selection.tiles) do
            v[1] = v[1] + moveMapX
            v[2] = v[2] + moveMapY
        end

        for _, v in ipairs(self.selection.borders) do
            v[1] = v[1] + moveWorldX
            v[2] = v[2] + moveWorldY
        end
    end
end

function Editor:saveState()
    for i = 1, self.editorState-1 do
        table.remove(self.editorStates, 1) -- Todo: Garbage collection doesn't seem to find the state
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
