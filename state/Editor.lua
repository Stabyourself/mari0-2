Editor = class("Editor")
    
Editor.toolbarOrder = {"paint", "erase", "move", "portal", "select", "wand", "fill", "stamp"}
Editor.toolbarImg = {}

for _, v in ipairs(Editor.toolbarOrder) do
    table.insert(Editor.toolbarImg, love.graphics.newImage("img/editor/" .. v .. ".png"))
end

local checkerboardImg = love.graphics.newImage("img/editor/checkerboard.png")
local selectionBorderImg = love.graphics.newImage("img/editor/selection-border.png")
selectionBorderImg:setWrap("repeat")

local selectionQuad = love.graphics.newQuad(0, 0, 16, 1, 4, 1)

Editor.toolClasses = {
    paint = require("class.editortools.Paint"),
    portal = require("class.editortools.Portal"),
    select = require("class.editortools.Select"),
    move = require("class.editortools.Move"),
    fill = require("class.editortools.Fill"),
    stamp = require("class.editortools.Stamp"),
    wand = require("class.editortools.Wand"),
    erase = require("class.editortools.Erase"),
}

Editor.scaleMin = 0.1/VAR("scale")
Editor.scaleMax = 1

function Editor:initialize(level)
    self.level = level
end

function Editor:load()
    self.tools = {}
    
    for i, v in pairs(self.toolClasses) do
        self.tools[i] = v:new(self)
    end
    
    self.canvas = GUI.Canvas:new(0, 0, SCREENWIDTH, SCREENHEIGHT)
    self.canvas.gui = defaultUI
    
    self.windows = {}
    
    -- MENU BAR
    self.menuBar = GUI.Canvas:new(0, 0, SCREENWIDTH, 14)
    self.menuBar.background = {1, 1, 1}
    self.menuBar.noClip = true
    
    self.canvas:addChild(self.menuBar)
    
    
    local fileDropdown = GUI.Dropdown:new(0, 0, "file")
    
    self.menuBar:addChild(fileDropdown)
    
    fileDropdown:autoSize()
    
    
    
    -- WINDOW
    
    self.newWindowDropdown = GUI.Dropdown:new(38, 0, "window")
    
    self.menuBar:addChild(self.newWindowDropdown)
    
    self.newWindowDropdown.box:addChild(GUI.Button:new(0, 0, "tiles", false, 1, function(button) self:newWindow("tiles", button) end))
    self.newWindowDropdown.box:addChild(GUI.Button:new(0, 10, "minimap", false, 1, function(button) self:newWindow("minimap", button) end))
    self.newWindowDropdown.box:addChild(GUI.Button:new(0, 20, "map options", false, 1, function(button) self:newWindow("mapOptions", button) end))
    self.newWindowDropdown.box:addChild(GUI.Button:new(0, 30, "test", false, 1, function(button) self:newWindow("test", button) end))
    
    self.newWindowDropdown:autoSize()
    
    
    
    -- VIEW
    
    local viewDropdown = GUI.Dropdown:new(92, 0, "view")
    
    self.menuBar:addChild(viewDropdown)
    
    viewDropdown.box:addChild(GUI.Checkbox:new(0, 0, "free camera", 1, function(checkbox) self:toggleFreeCam(checkbox.value) end, true))
    viewDropdown.box:addChild(GUI.Checkbox:new(0, 11, "draw grid", 1, function(checkbox) self:toggleGrid(checkbox.value) end))
    viewDropdown.box:addChild(GUI.Checkbox:new(0, 22, "hide ui", 1, function(checkbox) self:toggleUI(checkbox.value) end))
    
    viewDropdown:autoSize()
    
    
    
    -- SCALE BAR
    local w = 50
    local fullw = w+52
    local x = CAMERAWIDTH-fullw
    self.scaleBar = GUI.Canvas:new(x, 0, fullw, 14)
    self.menuBar:addChild(self.scaleBar)
    
    self.scaleSlider = GUI.Slider:new(self.scaleMin, self.scaleMax, 10, 3, w, false, function(val) self:changeScale(val) end)
    self.scaleSlider.color.bar = {0, 0, 0}
    
    self.scaleBar:addChild(self.scaleSlider)
    
    self:updateScaleSlider()
    
    self.scaleBar:addChild(GUI.Button:new(0, 2, "-", false, 1, function() self:zoom(-1) end))
    self.scaleBar:addChild(GUI.Button:new(w+10, 2, "+", false, 1, function() self:zoom(1) end))
    
    self.scaleBar:addChild(GUI.Button:new(w+24, 2, "1:1", false, 1, function() self:resetZoom() end))
    
    
    
    
    -- TOOL BAR
    self.toolbar = GUI.Canvas:new(0, 14, 14, CAMERAHEIGHT-14)
    self.toolbar.background = {255, 255, 255}
    self.canvas:addChild(self.toolbar)
    
    self.toolButtons = {}
    
    local y = 1
    for i, v in ipairs(self.toolbarOrder) do
        local button = GUI.Button:new(1, y, self.toolbarImg[i], false, 1, function(button) self:selectTool(v) end)
        
        self.toolButtons[v] = button
        
        button.color.img = {0, 0, 0}
        self.toolbar:addChild(button)
        
        y = y + 14
    end
    
    
    
    
    self:selectTool("paint")
    
    self.gridImg = love.graphics.newImage("img/grid.png")
    self.gridImg:setWrap("repeat", "repeat")
    self.gridQuad = love.graphics.newQuad(0, 0, 16, 16, 16, 16)
    
    self.selection = {}
    self.selectionBorders = {}
    self.selectionBorderTimer = 0
    
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
        
        if keyDown("right") then
            self.level.camera.x = self.level.camera.x + cameraSpeed
        end
        
        if keyDown("left") then
            self.level.camera.x = self.level.camera.x - cameraSpeed
        end
        
        if keyDown("down") then
            self.level.camera.y = self.level.camera.y + cameraSpeed
        end
        
        if keyDown("up") then
            self.level.camera.y = self.level.camera.y - cameraSpeed
        end
    end
    
    self.selectionBorderTimer = self.selectionBorderTimer + dt*8
    while self.selectionBorderTimer >= 4 do
        self.selectionBorderTimer = self.selectionBorderTimer - 4
    end
    selectionQuad:setViewport(math.floor(self.selectionBorderTimer), 0, 16, 1)
end

function Editor:draw()
    self.level.camera:attach()
    
    if self.showGrid then
        local xl, yt = self.level:cameraToWorld(0, 0)
        local xr, yb = self.level:cameraToWorld(CAMERAWIDTH, CAMERAHEIGHT)
        
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
    
    -- selection
    for _, v in ipairs(self.selectionBorders) do
        love.graphics.draw(selectionBorderImg, selectionQuad, v.x, v.y, v.a)
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
    if self.tool and self.tool.unselect then
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
    local y = button.y+button.h-1
    
    self.newWindowDropdown:toggle(false)

    if type == "test" then
        local testWindow = GUI.Box:new(10, y, 100, 100)
        testWindow.draggable = true
        testWindow.resizeable = true
        testWindow.closeable = true
        testWindow.scrollable = {true, true}
        testWindow.title = "Why did you press"
        testWindow.background = self.level.backgroundColor
        
        self.canvas:addChild(testWindow)
        
        
        for y = 0, 80, 20 do
            local text = GUI.Text:new("Important", 0, y)
            testWindow:addChild(text)
            
            local slider = GUI.Slider:new(0, 100, 0, y+9, 100, true)
            
            testWindow:addChild(slider)
        end
        
        
        local testWindow2 = GUI.Box:new(10, 30, 100, 100)
        testWindow2.draggable = true
        testWindow2.resizeable = true
        testWindow2.closeable = true
        testWindow2.scrollable = {true, true}
        testWindow2.title = ":<"
        testWindow2.background = self.level.backgroundColor
        
        testWindow:addChild(testWindow2)
        
        testWindow2:addChild(GUI.Button:new(5, 5, "don't hurt me!", true))
        
    elseif type == "tiles" then
        local tileListWindow = GUI.Box:new(10, y, 8*17+15, 200)
        tileListWindow.draggable = true
        tileListWindow.resizeable = true
        tileListWindow.closeable = true
        tileListWindow.scrollable = {true, true}
        tileListWindow.title = "tiles"
        tileListWindow.background = checkerboardImg
        
        self.canvas:addChild(tileListWindow)
        
        
        -- local backButton = GUI.Button:new(0, 0, "< back", true, 1, function() print("woah") end)
        -- tileListWindow:addChild(backButton)
        
        
        local tileListButtonGrid = GUI.ButtonGrid:new(1, 1, self.level.tileMaps.smb3.img, self.level.tileMaps.smb3.quad, 
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
    
    self.tools.paint.tile = self.level.tileMaps.smb3.tiles[i]
end

function Editor:keypressed(key)
    if self.tool.keypressed and self.tool:keypressed(key) then
        return true
    end
    
    if key == getKey("editor.delete") then
        for _, v in ipairs(self.selection) do
            self.level:setMap(v.x, v.y, nil)
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

function Editor:clearSelection()
    self.selection = {}
    self:updateSelectionBorder()
end

function Editor:replaceSelection(selection)
    self.selection = selection
    self:updateSelectionBorder()
end

function Editor:addToSelection(selection)
    for _, v in ipairs(selection) do
        local found = false
        
        for _, w in ipairs(self.selection) do
            if w.x == v.x and w.y == v.y then
                found = true
                break
            end
        end
        
        if not found then
            table.insert(self.selection, v)
        end
    end
    
    self:updateSelectionBorder()
end

function Editor:subtractFromSelection(selection)
    local toDelete = {}
    
    for i, v in ipairs(self.selection) do
        local found = false
        
        for _, w in ipairs(selection) do
            if w.x == v.x and w.y == v.y then
                found = true
                break
            end
        end
        
        if found then
            table.insert(toDelete, i)
        end
    end
    
    for i = #toDelete, 1, -1 do
        table.remove(self.selection, toDelete[i])
    end
        
    
    self:updateSelectionBorder()
end

function Editor:intersectSelection(selection)
    local newSelection = {}
    
    for _, v in ipairs(selection) do
        local found = false
        
        for _, w in ipairs(self.selection) do
            if w.x == v.x and w.y == v.y then
                found = true
                break
            end
        end
        
        if found then
            table.insert(newSelection, v)
        end
    end
    
    self.selection = newSelection
    
    self:updateSelectionBorder()
end

function Editor:updateSelectionBorder()
    self.selectionBorders = {}
    local SBL = {} -- selectionBordersLookup
    
    for _, v in ipairs(self.selection) do
        local x, y = v.x, v.y
        
        if SBL[x-1] and SBL[x-1][y] and SBL[x-1][y].right then
            SBL[x-1][y].right = false
        end
        if SBL[x+1] and SBL[x+1][y] and SBL[x+1][y].left then
            SBL[x+1][y].left = false
        end
        if SBL[x] and SBL[x][y-1] and SBL[x][y-1].bottom then
            SBL[x][y-1].bottom = false
        end
        if SBL[x] and SBL[x][y+1] and SBL[x][y+1].top then
            SBL[x][y+1].top = false
        end
        
        if not SBL[x] then
            SBL[x] = {}
        end
        
        SBL[x][y] = {
            top = true,
            left = true,
            right = true,
            bottom = true
        }
        
        if SBL[x-1] and SBL[x-1][y] then
            SBL[x][y].left = false
        end
        if SBL[x+1] and SBL[x+1][y] then
            SBL[x][y].right = false
        end
        if SBL[x] and SBL[x][y-1] then
            SBL[x][y].top = false
        end
        if SBL[x] and SBL[x][y+1] then
            SBL[x][y].bottom = false
        end
    end
    
    for _, v in ipairs(self.selection) do
        local x, y = v.x, v.y
        local wx, wy = self.level:mapToWorld(x-1, y-1)
        
        if SBL[x][y].top then
            table.insert(self.selectionBorders, {x=wx, y=wy, a=0})
        end
        
        if SBL[x][y].right then
            table.insert(self.selectionBorders, {x=wx+16, y=wy, a=math.pi*.5})
        end
        
        if SBL[x][y].bottom then
            table.insert(self.selectionBorders, {x=wx+16, y=wy+16, a=math.pi})
        end
        
        if SBL[x][y].left then
            table.insert(self.selectionBorders, {x=wx, y=wy+16, a=-math.pi*.5})
        end
    end
end

function Editor:expandMapTo(x, y)
    local moveMapX, moveMapY, moveWorldX, moveWorldY = self.level:expandMapTo(x, y)
    
    for _, v in ipairs(self.selection) do
        v.x = v.x + moveMapX
        v.y = v.y + moveMapY
    end
    
    for _, v in ipairs(self.selectionBorders) do
        v.x = v.x + moveWorldX
        v.y = v.y + moveWorldY
    end
end
