Editor = class("Editor")
    
Editor.toolbarOrder = {"paint", "move", "portal", "select", "pick", "fill", "stamp"}
Editor.toolbarImg = {}

for _, v in ipairs(Editor.toolbarOrder) do
    table.insert(Editor.toolbarImg, love.graphics.newImage("img/editor/" .. v .. ".png"))
end

local checkerboardImg = love.graphics.newImage("img/checkerboard.png")

Editor.toolClasses = {
    paint = require("class.editortools.Paint"),
    portal = require("class.editortools.Portal"),
    select = require("class.editortools.Select"),
    move = require("class.editortools.Move"),
    fill = require("class.editortools.Fill"),
    stamp = require("class.editortools.Stamp"),
    pick = require("class.editortools.Pick"),
}

Editor.scaleMin = 1/VAR("scale")
Editor.scaleMax = 2

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
    
    viewDropdown.box:addChild(GUI.Checkbox:new(0, 0, "draw grid", 1, function(checkbox) self:toggleGrid(checkbox.value) end))
    viewDropdown.box:addChild(GUI.Checkbox:new(0, 11, "hide ui", 1, function(checkbox) self:toggleUI(checkbox.value) end))
    
    viewDropdown:autoSize()
    
    
    
    -- SCALE BAR
    local w = 50
    local x = CAMERAWIDTH-w-3-9-34
    self.scaleSlider = GUI.Slider:new(self.scaleMin, self.scaleMax, x, 3, w, false, function(val) self:changeScale(val) end)
    self.scaleSlider.color.bar = {0, 0, 0}
    
    self.menuBar:addChild(self.scaleSlider)
    
    self:updateScaleSlider()
    
    self.menuBar:addChild(GUI.Button:new(x-10, 2, "-", false, 1, function() self:zoom(-1) end))
    self.menuBar:addChild(GUI.Button:new(x+w, 2, "+", false, 1, function() self:zoom(1) end))
    
    self.menuBar:addChild(GUI.Button:new(x+w+10, 2, "100%", false, 1, function() self:resetZoom() end))
    
    
    
    
    -- TOOL BAR
    self.toolbar = GUI.Canvas:new(0, 14, 14, CAMERAHEIGHT-14)
    self.toolbar.background = {255, 255, 255}
    self.canvas:addChild(self.toolbar)
    
    
    local y = 1
    for i, v in ipairs(self.toolbarOrder) do
        local button = GUI.Button:new(1, y, self.toolbarImg[i], false, 1, function(button) self:selectTool(self.tools[v]) end)
        button.color.img = {0, 0, 0}
        self.toolbar:addChild(button)
        
        y = y + 14
    end
    
    
    
    
    self:selectTool(self.tools.portal)
    self:selectTool(self.tools.paint)
    
    self.showGrid = false
    self.gridImg = love.graphics.newImage("img/grid.png")
    self.gridImg:setWrap("repeat", "repeat")
    self.gridQuad = love.graphics.newQuad(0, 0, 16, 16, 16, 16)
end

function Editor:update(dt)
    self.canvas:update(dt)
    
    self.tool:update(dt)
    
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
    
    self.tool:draw()
    
    self.level.camera:detach()
    
    self.canvas:draw()
end

function Editor:changeScale(val)
    self.level.camera:zoomTo(val)
end

function Editor:updateScaleSlider()
    self.scaleSlider:setValue(self.level.camera.scale)
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

function Editor:selectTool(tool)
    if self.tool then
        self.tool:unSelect()
    end
    
    self.tool = tool
    
    self.tool:select()
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
        testWindow2.title = "Why did you press"
        testWindow2.background = self.level.backgroundColor
        
        testWindow:addChild(testWindow2)
        
    elseif type == "tiles" then
        local tileListWindow = GUI.Box:new(10, y, 8*17+15, 200)
        tileListWindow.draggable = true
        tileListWindow.resizeable = true
        tileListWindow.closeable = true
        tileListWindow.scrollable = {true, true}
        tileListWindow.title = "tiles"
        tileListWindow.background = checkerboardImg
        
        self.canvas:addChild(tileListWindow)
        
        
        local backButton = GUI.Button:new(0, 0, "< back", true, 1, function() print("woah") end)
        tileListWindow:addChild(backButton)
        
        
        local tileListButtonGrid = GUI.ButtonGrid:new(1, 20, self.level.tileMap.img, self.level.tileMap.quad, 
            function(buttonGrid, i) 
                buttonGrid.selected = i
                self:selectTile(i) 
            end
        )
        tileListWindow:addChild(tileListButtonGrid)
        
    end
end

function Editor:selectTile(i)
    self.tool = self.tools.paint
    self.tools.paint.tile = i
end

function Editor:keypressed(key)
    
end

function Editor:mousepressed(x, y, button)
    if self.canvas:mousepressed(x, y, button) then -- don't do tool stuff if the click was on a GUI element
        return true
    end
    
    return self.tool:mousepressed(x, y, button)
end

function Editor:mousereleased(x, y, button)
    self.canvas:mousereleased(x, y, button)
    
    self.tool:mousereleased(x, y, button)
end

function Editor:wheelmoved(x, y)
    if self.canvas:wheelmoved(x, y) then
        return true
    end

    if y ~= 0 then
        self:zoom(y)
    end
end

function Editor:zoom(i)
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
    
    self.level.camera:zoom(zoom, getWorldMouse())
    
    self:updateScaleSlider()
end
    
function Editor:resetZoom()
    self.level.camera:zoomTo(1)
    self:updateScaleSlider()
end

function Editor:resize(w, h)
    self.canvas:resize(w, h)
    self.menuBar:resize(w, self.menuBar.h)
    self.toolbar.h = CAMERAHEIGHT-14
end