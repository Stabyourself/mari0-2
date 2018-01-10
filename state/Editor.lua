Editor = class("Editor")

local checkerboardImg = love.graphics.newImage("img/checkerboard.png")

function Editor:load()
    self.canvas = GUI.Canvas:new(defaultUI, 0, 0, SCREENWIDTH, SCREENHEIGHT)
    self.windows = {}
    
    self.canvas:addChild(GUI.Button:new(10, 30, "don't press", function(button) self:newWindow("test", button) end))
    self.canvas:addChild(GUI.Button:new(10, 10, "open tiles", function(button) self:newWindow("tileList", button) end))
    
    self.canvas:addChild(GUI.Checkbox:new(10, 50, "draw grid", function(checkbox) self:toggleGrid(checkbox.value) end))
    
    self.tool = "paint"
    
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
        local x, y = game.level:screenToMap(getWorldMouse())
        
        game.level:setMap(x, y, self.paint.tile)
    end
end

function Editor:draw()
    if self.tool == "paint" then
        local mouseX, mouseY = getWorldMouse()
        local mapX, mapY = game.level:screenToMap(mouseX, mouseY)
        local worldX, worldY = game.level:mapToScreen(mapX-1, mapY-1)
        
        game.level.tileMap.tiles[self.paint.tile]:draw(worldX, worldY, true)
    end
    
    if self.showGrid then
        self.gridQuad:setViewport(game.level.camera.x%game.level.tileSize, game.level.camera.y%game.level.tileSize, CAMERAWIDTH+game.level.tileSize, CAMERAHEIGHT+game.level.tileSize)
        love.graphics.draw(self.gridImg, self.gridQuad, 0, 0)
    end
    
    self.canvas:draw()
end

function Editor:toggleGrid(on)
    self.showGrid = on
end

function Editor:newWindow(type, button)
    local y = button.y+button.h-1

    if type == "test" then
        local testWindow = GUI.Box:new(10, y, 100, 100)
        testWindow.draggable = true
        testWindow.resizeable = true
        testWindow.closeable = true
        testWindow.scrollable = {true, true}
        testWindow.title = "Why did you press"
        testWindow.background = game.level.backgroundColor
        
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
        -- testWindow2.background = game.level.backgroundColor
        
        -- testWindow:addChild(testWindow2)
        
    elseif type == "tileList" then
        local tileListWindow = GUI.Box:new(10, y, 200, 200)
        tileListWindow.draggable = true
        tileListWindow.resizeable = true
        tileListWindow.closeable = true
        tileListWindow.scrollable = {true, true}
        tileListWindow.title = "tiles"
        tileListWindow.background = checkerboardImg
        
        self.canvas:addChild(tileListWindow)
        
        
        local backButton = GUI.Button:new(0, 0, "< back", function() print("woah") end)
        tileListWindow:addChild(backButton)
        
        
        local tileListButtonGrid = GUI.ButtonGrid:new(5, 20, game.level.tileMap.img, game.level.tileMap.quad, function(buttonGrid, i) self:selectTile(i) end)
        tileListWindow:addChild(tileListButtonGrid)
        
    end
end

function Editor:pipette(x, y)
    local mapX, mapY = game.level:screenToMap(getWorldMouse())
    
    self.paint.tile = game.level.map[mapX][mapY]
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
    self.canvas:wheelmoved(x, y)
end

function Editor:resize(w, h)
    self.canvas:resize(w, h)
end