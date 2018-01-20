local Entity = class("Editor.Entity")

function Entity:initialize(editor)
    self.editor = editor
    
    self.level = self.editor.level
end

return Entity
