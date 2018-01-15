EditorState = class("EditorState")

function EditorState:initialize(editor)
    self.editor = editor

    self.state = self:serialize()
end

function EditorState:serialize()
    local state = {}

    state.map = {}
    state.width = self.editor.level.width
    state.height = self.editor.level.height

    for x = 1, state.width do
        state.map[x] = {}

        for y = 1, state.height do
            state.map[x][y] = self.editor.level.map[x][y]
        end
    end
    
    state.selection = {}
    
    for _, v in ipairs(self.editor.selection) do
        table.insert(state.selection, {v[1], v[2]})
    end

    return state
end

function EditorState:load()
    self.editor.level.map = {}
    
    for x = 1, self.state.width do
        self.editor.level.map[x] = {}

        for y = 1, self.state.height do
            self.editor.level.map[x][y] = self.state.map[x][y]
        end
    end
    
    self.editor.level.width = self.state.width
    self.editor.level.height = self.state.height
    
    self.editor.selection = {}
    for _, v in ipairs(self.state.selection) do
        table.insert(self.editor.selection, {v[1], v[2]})
    end
    self.editor:updateSelectionBorder()
end