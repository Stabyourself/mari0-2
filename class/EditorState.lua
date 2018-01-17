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
    
    local selection = self.editor.selection
    
    if selection then
        state.selection = {}
        state.selection.tiles = {}
        
        for _, v in ipairs(selection.tiles) do
            table.insert(state.selection.tiles, {v[1], v[2]})
        end
    end

    local floatingSelection = self.editor.floatingSelection

    if floatingSelection then
        state.floatingSelection = {}
        state.floatingSelection.pos = {floatingSelection.pos[1], floatingSelection.pos[2]}
        state.floatingSelection.width = floatingSelection.width
        state.floatingSelection.height = floatingSelection.height
        
        state.floatingSelection.tiles = {}
        for _, v in ipairs(floatingSelection.tiles) do
            table.insert(state.floatingSelection.tiles, {v[1], v[2]})
        end

        state.floatingSelection.floatMap = {}
        for x = 1, floatingSelection.width do
            state.floatingSelection.floatMap[x] = {}

            for y = 1, floatingSelection.height do
                state.floatingSelection.floatMap[x][y] = floatingSelection.floatMap[x][y]
            end
        end
    end

    return state
end

function EditorState:load()
    local state = self.state
    self.editor.level.map = {}
    
    for x = 1, state.width do
        self.editor.level.map[x] = {}

        for y = 1, state.height do
            self.editor.level.map[x][y] = state.map[x][y]
        end
    end
    
    self.editor.level.width = state.width
    self.editor.level.height = state.height
    
    self.editor.selection = nil
    self.editor.floatingSelection = nil
    
    if state.selection then
        local tiles = {}
        for _, v in ipairs(state.selection.tiles) do
            table.insert(tiles, {v[1], v[2]})
        end
        
        local selection = Selection:new(self.editor, tiles)
        self.editor.selection = selection
    end

    if state.floatingSelection then
        local tiles = {}
        for _, v in ipairs(state.floatingSelection.tiles) do
            table.insert(tiles, {v[1], v[2]})
        end

        self.editor.floatingSelection = FloatingSelection:new(self.editor, tiles)
        self.editor.floatingSelection.pos[1] = state.floatingSelection.pos[1]
        self.editor.floatingSelection.pos[2] = state.floatingSelection.pos[2]

        self.editor.floatingSelection.floatMap = {}
        for x = 1, state.floatingSelection.width do
            self.editor.floatingSelection.floatMap[x] = {}

            for y = 1, state.floatingSelection.height do
                self.editor.floatingSelection.floatMap[x][y] = state.floatingSelection.floatMap[x][y]
            end
        end
    end
end