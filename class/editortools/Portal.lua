local Portal = class("Editor.Portal")

function Portal:initialize(editor)
    self.editor = editor
end

function Portal:select()
    self.editor.level.camera.target = self.editor.level.marios[1]
    self.editor.level.controlsEnabled = true
    self.editor.freeCamera = false
end

function Portal:unSelect()
    self.editor.level.camera.target = nil
    self.editor.level.controlsEnabled = false
    self.editor.freeCamera = true
end

function Portal:update(dt)
    
end

function Portal:draw()
    
end

function Portal:mousepressed(x, y, button)
    
end

function Portal:mousereleased(x, y, button)
    
end

return Portal
