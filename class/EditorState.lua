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
        
        for _, tile in ipairs(selection.tiles) do
            table.insert(state.selection.tiles, {tile[1], tile[2]})
        end
    end

    local floatingSelection = self.editor.floatingSelection

    if floatingSelection then
        state.floatingSelection = floatingSelection:getStampMap()
        state.floatingSelectionPos = {floatingSelection.pos[1], floatingSelection.pos[2]}
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
        for _, tile in ipairs(state.selection.tiles) do
            table.insert(tiles, {tile[1], tile[2]})
        end
        
        local selection = Selection:new(self.editor, tiles)
        self.editor.selection = selection
    end

    if state.floatingSelection then
        self.editor.floatingSelection = FloatingSelection:new(self.editor, state.floatingSelection, state.floatingSelectionPos)
        self.editor.floatingSelection.pos = {state.floatingSelectionPos[1], state.floatingSelectionPos[2]}
    end
end