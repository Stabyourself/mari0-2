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

function editor.newWindow(type)
    if type == "test" then
        editor.windows.testWindow = GUI.Box:new(64, 16, 92, 109)
        editor.windows.testWindow.draggable = true
        editor.windows.testWindow.resizeable = true
        editor.windows.testWindow.closeable = true
        editor.windows.testWindow.title = "virus.exe"
        editor.windows.testWindow.backgroundColor = game.level.backgroundColor
        
        editor.canvas:addChild(editor.windows.testWindow)
        
        
        local bla = GUI.Box:new(64, 16, 40, 40)
        bla.draggable = true
        bla.resizeable = true
        bla.closeable = true
        bla.title = "virus.exe"
        bla.backgroundColor = game.level.backgroundColor
        
        editor.windows.testWindow:addChild(bla)
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