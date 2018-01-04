editor = {}

function editor.load()
    editor.canvas = GUI.Canvas:new(defaultUI, 0, 0, SCREENWIDTH, SCREENHEIGHT)
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
        local testWindow = GUI.Box:new(10, 30, 150, 100)
        testWindow.draggable = true
        testWindow.resizeable = true
        testWindow.closeable = true
        testWindow.scrollable = {true, true}
        testWindow.title = "Is this the best element?"
        testWindow.backgroundColor = game.level.backgroundColor
        
        editor.canvas:addChild(testWindow)
        
        for y = 5, 70, 20 do
            local text = GUI.Text:new("Important", 5, y)
            testWindow:addChild(text)
            
            local slider = GUI.Slider:new(0, 100, 5, y+9, 190, true)
            
            testWindow:addChild(slider)
        end
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