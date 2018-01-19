local Move = class("Editor.Move")

function Move:initialize(editor)
    self.editor = editor
    
    self.level = self.editor.level
end

return Move
