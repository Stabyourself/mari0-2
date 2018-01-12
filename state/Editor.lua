Editor = class("Editor")

local checkerboardImg = love.graphics.newImage("img/checkerboard.png")

function Editor:initialize(level)
    self.level = level
end

function Editor:load()
    self.canvas = GUI.Canvas:new(0, 0, SCREENWIDTH, SCREENHEIGHT)
    self.canvas.gui = defaultUI
    
    self.windows = {}
    
    self.menuBar = GUI.Canvas:new(0, 0, SCREENWIDTH, 14)
    self.menuBar.background = {255, 255, 255}
    self.menuBar.noClip = true
    
    self.canvas:addChild(self.menuBar)
    
    
    local fileDropdown = GUI.Dropdown:new(0, 0, "file")
    
    self.menuBar:addChild(fileDropdown)
    
    fileDropdown:autoSize()
    
    
    
    self.newWindowDropdown = GUI.Dropdown:new(38, 0, "window")
    
    self.menuBar:addChild(self.newWindowDropdown)
    
    self.newWindowDropdown.box:addChild(GUI.Button:new(0, 0, "tiles", false, 1, function(button) self:newWindow("tiles", button) end))
    self.newWindowDropdown.box:addChild(GUI.Button:new(0, 10, "minimap", false, 1, function(button) self:newWindow("tiles", button) end))
    self.newWindowDropdown.box:addChild(GUI.Button:new(0, 20, "map options", false, 1, function(button) self:newWindow("tiles", button) end))
    
    self.newWindowDropdown:autoSize()
    
    
    
    
    local viewDropdown = GUI.Dropdown:new(92, 0, "view")
    
    self.menuBar:addChild(viewDropdown)
    
    viewDropdown.box:addChild(GUI.Checkbox:new(0, 0, "draw grid", 1, function(checkbox) self:toggleGrid(checkbox.value) end))
    viewDropdown.box:addChild(GUI.Checkbox:new(0, 11, "autoscroll", 1, function(checkbox)  end))
    
    
    viewDropdown:autoSize()
    -- self.menuBar:addChild(GUI.Button:new(100, 0, "don't press", function(button) self:newWindow("test", button) end))
    
    -- self.menuBar:addChild())
    
    self:selectTool("paint")
    
    self.paint = {
        tile = 1,
        penDown = false,
    }
    
    self.showGrid = false
    self.gridImg = love.graphics.newImage("img/grid.png")
    self.gridImg:setWrap("repeat", "repeat")
    self.gridQuad = love.graphics.newQuad(0, 0, 16, 16, 16, 16)
end

function Editor:update(dt)
    self.canvas:update(dt)
    
    if self.paint.penDown then
        local x, y = self.level:cameraToMap(getWorldMouse())
        
        self.level:setMap(x, y, self.paint.tile)
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
end

function Editor:draw()
    self.level.camera:attach()
    
    if self.tool == "paint" then
        local mouseX, mouseY = getWorldMouse()
        local mapX, mapY = self.level:cameraToMap(mouseX, mouseY)
        local worldX, worldY = self.level:mapToWorld(mapX-1, mapY-1)
        
        self.level.tileMap.tiles[self.paint.tile]:draw(worldX, worldY, true)
    end
    
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
    
    self.level.camera:detach()
    
    self.canvas:draw()
end

function Editor:toggleGrid(on)
    self.showGrid = on
end

function Editor:selectTool(tool)
    self.tool = tool
    
    if self.tool == "portal" then
        self.level.camera.target = self.level.marios[1]
        self.level.controlsEnabled = true
        self.freeCamera = false
    else
        self.level.camera.target = nil
        self.level.controlsEnabled = false
        self.freeCamera = true
    end
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
        
        
        -- local testWindow2 = GUI.Box:new(10, 30, 100, 100)
        -- testWindow2.draggable = true
        -- testWindow2.resizeable = true
        -- testWindow2.closeable = true
        -- testWindow2.scrollable = {true, true}
        -- testWindow2.title = "Why did you press"
        -- testWindow2.background = self.level.backgroundColor
        
        -- testWindow:addChild(testWindow2)
        
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

function Editor:pipette(x, y)
    local mapX, mapY = self.level:mouseToMap()
    
    if self.level:inMap(mapX, mapY) then
        self.paint.tile = self.level.map[mapX][mapY]
    end
end

function Editor:selectTile(i)
    self.tool = "paint"
    self.paint.tile = i
end

function Editor:keypressed(key)
    
end

function Editor:mousepressed(x, y, button)
    if self.canvas:mousepressed(x, y, button) then -- don't do tool stuff if the click was on a GUI element
        return true
    end
    
    if self.tool == "paint" then
        if (button == 1 and keyDown("editor.pipette")) or button == 3 then
            self:pipette(x, y)
            
        elseif button == 1 then
            self.paint.penDown = true
            
        end
    end

    if self.tool ~= "portal" then
        return true
    end
end

function Editor:mousereleased(x, y, button)
    self.canvas:mousereleased(x, y, button)
    
    if self.tool == "paint" then
        self.paint.penDown = false
    end
end

function Editor:wheelmoved(x, y)
    if self.canvas:wheelmoved(x, y) then
        return true
    end

    if y ~= 0 then
        local zoom
         
        if y > 0 then -- out
            zoom = 1.1^y
        else
            zoom = 1/(1.1^-y)
        end
        
        self.level.camera:zoom(zoom, getWorldMouse())
    end
end

function Editor:resize(w, h)
    self.canvas:resize(w, h)
    self.menuBar:resize(w, self.menuBar.h)
end