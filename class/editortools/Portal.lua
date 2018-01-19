local Portal = class("Editor.Portal")

function Portal:initialize(editor)
    self.editor = editor
    
    self.level = self.editor.level
end

function Portal:select()
    self.level.controlsEnabled = true
    self.editor.freeCamera = false
end

function Portal:unSelect()
    self.level.controlsEnabled = false
    self.editor.freeCamera = true
end

return Portal
