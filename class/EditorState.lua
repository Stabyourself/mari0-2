EditorState = class("EditorState")

function EditorState:initialize(editor)
    self.editor = editor

    self.state = self:serialize()
end

function EditorState:serialize()
    local state = {}

    state.map = {}

    for x = 1, self.editor.level.width do
        state.map[x] = {}

        for y = 1, self.editor.level.height do
            state.map[x][y] = self.editor.level.map[x][y]
        end
    end

    return state
end

function EditorState:load()
    self.editor.level.map = self.state.map
end