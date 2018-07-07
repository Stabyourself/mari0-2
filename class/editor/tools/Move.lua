local Move = class("Editor.Move")

function Move:initialize(editor)
    self.editor = editor

    self.level = self.editor.level
    self.moving = false
end

function Move:mousepressed(x, y, button)
    self.moving = true
    love.mouse.setRelativeMode(true)

    return true
end

function Move:mousereleased(x, y, button)
    self.moving = false
    love.mouse.setRelativeMode(false)
end

function Move:mousemoved(x, y)
    if self.moving then
        self.editor:toggleFreeCam(true)

        local camera = self.editor.level.camera
        camera:move(-x/camera.scale, -y/camera.scale)
    end
end

return Move
