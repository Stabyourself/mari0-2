EditorState = class("EditorState")

function EditorState:initialize(editor)
    self.editor = editor

    self.state = self:serialize()
end

function EditorState:serialize()
    local world = self.editor.level
    local state = {}

    -- Layers
    state.layers = {}

    for i, layer in ipairs(world.layers) do
        state.layers[i] = {}

        state.layers[i].x = layer.x
        state.layers[i].y = layer.y
        state.layers[i].width = layer.width
        state.layers[i].height = layer.height

        state.layers[i].map = {}

        for x = 1, layer.width do
            state.layers[i].map[x] = {}

            for y = 1, layer.height do
                state.layers[i].map[x][y] = layer.map[x][y]
            end
        end
    end

    -- Selection
    local selection = self.editor.selection

    if selection then
        state.selection = {}
        state.selection.tiles = {}

        for _, tile in ipairs(selection.tiles) do
            table.insert(state.selection.tiles, {tile[1], tile[2]})
        end
    end

    -- Selection but in red
    local floatingSelection = self.editor.floatingSelection

    if floatingSelection then
        state.floatingSelection = floatingSelection:getStampMap()
        state.floatingSelectionPos = {floatingSelection.pos[1], floatingSelection.pos[2]}
    end

    return state
end

function EditorState:load()
    local state = self.state
    local world = self.editor.level

    world.layers = {}

    for i, layer in ipairs(state.layers) do
        local map = {}

        for x = 1, layer.width do
            map[x] = {}

            for y = 1, layer.height do
                map[x][y] = layer.map[x][y]
            end
        end

        world.layers[i] = Layer:new(world, layer.x, layer.y, layer.width, layer.height, map)
    end

    self.editor.activeLayer = self.editor.level.layers[1]

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
        self.editor.floatingSelection = FloatingSelection:new(
            self.editor,
            state.floatingSelection,
            state.floatingSelectionPos
        )
        self.editor.floatingSelection.pos = {state.floatingSelectionPos[1], state.floatingSelectionPos[2]}
    end
end