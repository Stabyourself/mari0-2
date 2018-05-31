local Move = class("Editor.Move")

function Move:initialize(editor)
    self.editor = editor

    self.level = self.editor.level
end

function Move:mousepressed(x, y, button)
    love.mouse.setRelativeMode(true)

    return true
end

function Move:mousereleased(x, y, button)
    love.mouse.setRelativeMode(false)
end

function Move:mousemoved(x, y)

end

return Move
