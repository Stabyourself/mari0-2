EditorState = class("EditorState")

function EditorState:initialize(editor)
    self.editor = editor

    self.state = self:serialize()
    print("state saved")
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
        
        if self.editor.floatingSelection then
            state.selection.box = {selection.box[1], selection.box[2], selection.box[3], selection.box[4]}
            state.selection.width = selection.width
            state.selection.height = selection.height
            state.selection.totalOffset = {selection.totalOffset[1], selection.totalOffset[2]}
            state.selection.floatMap = {}
            
            for x = 1, selection.width do
                state.selection.floatMap[x] = {}
                
                for y = 1, selection.height do
                    state.selection.floatMap[x][y] = selection.floatMap[x][y]
                end
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
    
    if state.selection then
        local tiles = {}
        for _, v in ipairs(state.selection.tiles) do
            table.insert(tiles, {v[1], v[2]})
        end
        
        local selection = Selection:new(self.editor, tiles)
        self.editor.selection = selection
        
        selection.box = {state.selection.box[1], state.selection.box[2], state.selection.box[3], state.selection.box[4]}
        selection.width = state.selection.width
        selection.height = state.selection.height
        
        selection.floating = state.selection.floating
        
        if state.selection.floating then
            selection.totalOffset = {state.selection.totalOffset[1], state.selection.totalOffset[2]}
            
            selection.floatMap = {}
            
            for x = 1, selection.width do
                selection.floatMap[x] = {}
                
                for y = 1, selection.height do
                    selection.floatMap[x][y] = state.selection.floatMap[x][y]
                end
            end
        end
    else
        self.editor.selection = nil
    end
end