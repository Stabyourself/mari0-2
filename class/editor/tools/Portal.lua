local Portal = class("Editor.Portal")

function Portal:initialize(editor)
    self.editor = editor

    self.level = self.editor.level
end

return Portal
