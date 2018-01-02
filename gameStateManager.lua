gameStateManager = {}
gameStateManager.activeStates = {}

function gameStateManager.loadState(state)
    print("Changing state.")
    gameStateManager.activeStates = {state}
    gameStateManager.event("load")
end

function gameStateManager.addState(state)
    table.insert(gameStateManager.activeStates, state)
    state.load()
end

function gameStateManager.event(event, ...)
    for _, v in ipairs(gameStateManager.activeStates) do
        if type(v[event]) == "function" then
            v[event](...)
        end
    end
end
