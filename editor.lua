editor = {}

function editor.load()
    editor.canvas = GUI.Canvas:new(defaultUI, 0, 0, SCREENWIDTH, SCREENHEIGHT)
    editor.canvas.scrollable[1] = true
    editor.canvas.scrollable[2] = true
    editor.windows = {}
    
    editor.buttons = {}
    
    editor.buttons.newTestWindow = GUI.Button:new(10, 10, "edgar anti virus", function() editor.newWindow("test") end)
    editor.canvas:addChild(editor.buttons.newTestWindow)
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
        testWindow.scrollable = {true, true}
        testWindow.backgroundColor = game.level.backgroundColor
        
        editor.canvas:addChild(testWindow)
        
        local testWindow2 = GUI.Box:new(10, 30, 150, 100)
        testWindow2.resizeable = true
        testWindow2.draggable = true
        testWindow2.closeable = true
        testWindow2.scrollable = {true, false}
        testWindow:addChild(testWindow2)

        local testWindow3 = GUI.Box:new(10, 30, 150, 100)
        testWindow3.resizeable = true
        testWindow3.draggable = true
        testWindow3.closeable = true
        testWindow3.scrollable = {true, false}
        testWindow2:addChild(testWindow3)
        
        -- for y = 0, 80, 20 do
        --     local text = GUI.Text:new("Important", 0, y)
        --     testWindow:addChild(text)
            
        --     local slider = GUI.Slider:new(0, 100, 0, y+9, 100, true)
            
        --     testWindow:addChild(slider)
        -- end
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