editor = {}

function editor.load()
    editor.canvas = GUI.Canvas:new(defaultUI, 0, 0, SCREENWIDTH, SCREENHEIGHT)
    editor.windows = {}
    
    editor.buttons = {}
    
    editor.buttons.newTestWindow = GUI.Button:new(10, 30, "Don't press", function() editor.newWindow("test") end)
    editor.buttons.newTileListWindow = GUI.Button:new(10, 10, "open tilelist", function() editor.newWindow("tileList") end)
    editor.canvas:addChild(editor.buttons.newTestWindow)
    editor.canvas:addChild(editor.buttons.newTileListWindow)
end

function editor.update(dt)
    editor.canvas:update(dt)
end

function editor.draw()
    editor.canvas:draw()
end

function editor.newWindow(type, elem)
    if type == "test" then
        local testWindow = GUI.Box:new(10, 30, 100, 97)
        testWindow.draggable = true
        testWindow.resizeable = true
        testWindow.closeable = true
        testWindow.scrollable = {x=true, y=true}
        testWindow.title = "Why did you press"
        testWindow.backgroundColor = game.level.backgroundColor
        
        editor.canvas:addChild(testWindow)
        
        for y = 0, 80, 20 do
            local text = GUI.Text:new("Important", 0, y)
            testWindow:addChild(text)
            
            local slider = GUI.Slider:new(0, 100, 0, y+9, 100, true)
            
            testWindow:addChild(slider)
        end
        
    elseif type == "tileList" then
        local tileListWindow = GUI.Box:new(10, 20, 200, 200)
        tileListWindow.draggable = true
        tileListWindow.resizeable = true
        tileListWindow.closeable = true
        tileListWindow.scrollable = {x=true, y=true}
        tileListWindow.title = "tilelist"
        tileListWindow.backgroundColor = game.level.backgroundColor
        editor.canvas:addChild(tileListWindow)
        
        local text = GUI.Text:new("Awesomeness", 5, 5)
        tileListWindow:addChild(text)
        
        local slider = GUI.Slider:new(0, 11, 5, 14, 100, true)
        tileListWindow:addChild(slider)
        
        
        local tileListButtonGrid = GUI.ButtonGrid:new(5, 30, game.level.tileMap.img, game.level.tileMap.quad, function(i) print("Holy shit you clicked tile number " .. i) end)
        tileListWindow:addChild(tileListButtonGrid)
    end
end

function editor.keypressed(key)
    
end

function editor.mousepressed(x, y, button)
    editor.canvas:mousepressed(x, y, button)
end

function editor.mousereleased(x, y, button)
    editor.canvas:mousereleased(x, y, button)
end

function editor.resize(w, h)
    editor.canvas.w = w
    editor.canvas.h = h 
end