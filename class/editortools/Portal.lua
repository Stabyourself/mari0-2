local Portal = class("Editor.Portal")

function Portal:initialize(editor)
    self.editor = editor
end

function Portal:select()
    self.editor.level.controlsEnabled = true
    self.editor.freeCamera = false
end

function Portal:unSelect()
    self.editor.level.controlsEnabled = false
    self.editor.freeCamera = true
end

return Portal
