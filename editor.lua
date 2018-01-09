editor = {}

local checkerboardImg = love.graphics.newImage("img/checkerboard.png")

function editor.load()
    editor.canvas = GUI.Canvas:new(defaultUI, 0, 0, SCREENWIDTH, SCREENHEIGHT)
    editor.windows = {}
    
    editor.canvas:addChild(GUI.Button:new(10, 30, "don't press", function() editor.newWindow("test") end))
    editor.canvas:addChild(GUI.Button:new(10, 10, "open tiles", function() editor.newWindow("tileList") end))
    
    editor.canvas:addChild(GUI.Checkbox:new(10, 50, "draw grid", function(checkbox) editor.toggleGrid(checkbox.value) end))
    
    editor.tool = "paint"
    
    editor.paint = {
        tile = 1,
        penDown = false,
    }
    
    editor.showGrid = false
    editor.gridImg = love.graphics.newImage("img/grid.png")
    editor.gridImg:setWrap("repeat", "repeat")
    editor.gridQuad = love.graphics.newQuad(0, 0, 16, 16, 16, 16)
end

function editor.update(dt)
    editor.canvas:update(dt)
    
    if editor.paint.penDown then
        local x, y = game.level:screenToMap(getWorldMouse())
        
        game.level:setMap(x, y, editor.paint.tile)
    end
end

function editor.draw()
    if editor.tool == "paint" then
        local mouseX, mouseY = getWorldMouse()
        local mapX, mapY = game.level:screenToMap(mouseX, mouseY)
        local worldX, worldY = game.level:mapToScreen(mapX-1, mapY-1)
        
        game.level.tileMap.tiles[editor.paint.tile]:draw(worldX, worldY, true)
    end
    
    if editor.showGrid then
        editor.gridQuad:setViewport(game.level.camera.x%game.level.tileSize, game.level.camera.y%game.level.tileSize, CAMERAWIDTH+game.level.tileSize, CAMERAHEIGHT+game.level.tileSize)
        love.graphics.draw(editor.gridImg, editor.gridQuad, 0, 0)
    end
    
    editor.canvas:draw()
end

function editor.toggleGrid(on)
    editor.showGrid = on
end

function editor.newWindow(type, elem)
    if type == "test" then
        local testWindow = GUI.Box:new(10, 30, 100, 100)
        testWindow.draggable = true
        testWindow.resizeable = true
        testWindow.closeable = true
        testWindow.scrollable = {x=true, y=true}
        testWindow.title = "Why did you press"
        testWindow.background = game.level.backgroundColor
        
        editor.canvas:addChild(testWindow)
        
        
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
        -- testWindow2.scrollable = {x=true, y=true}
        -- testWindow2.title = "Why did you press"
        -- testWindow2.background = game.level.backgroundColor
        
        -- testWindow:addChild(testWindow2)
        
    elseif type == "tileList" then
        local tileListWindow = GUI.Box:new(10, 20, 200, 200)
        tileListWindow.draggable = true
        tileListWindow.resizeable = true
        tileListWindow.closeable = true
        tileListWindow.scrollable = {x=true, y=true}
        tileListWindow.title = "tiles"
        tileListWindow.background = checkerboardImg
        
        editor.canvas:addChild(tileListWindow)
        
        
        local backButton = GUI.Button:new(0, 0, "< back", function() print("woah") end)
        tileListWindow:addChild(backButton)
        
        
        local tileListButtonGrid = GUI.ButtonGrid:new(5, 20, game.level.tileMap.img, game.level.tileMap.quad, function(i) editor.selectTile(i) end)
        tileListWindow:addChild(tileListButtonGrid)
        
    end
end

function editor.pipette(x, y)
    local mapX, mapY = game.level:screenToMap(getWorldMouse())
    
    editor.paint.tile = game.level.map[mapX][mapY]
end

function editor.selectTile(i)
    editor.tool = "paint"
    editor.paint.tile = i
end

function editor.keypressed(key)
    
end

function editor.mousepressed(x, y, button)
    if editor.canvas:mousepressed(x, y, button) then -- don't do tool stuff if the click was on a GUI element
        return
    end
    
    if editor.tool == "paint" then
        if (button == 1 and keyDown("editor.pipette")) or button == 3 then
            editor.pipette(x, y)
            
        elseif button == 1 then
            editor.paint.penDown = true
            
        end
    end
end

function editor.mousereleased(x, y, button)
    editor.canvas:mousereleased(x, y, button)
    
    if editor.tool == "paint" then
        editor.paint.penDown = false
    end
end

function editor.wheelmoved(x, y)
    editor.canvas:wheelmoved(x, y)
end

function editor.resize(w, h)
    editor.canvas:resize(w, h)
end