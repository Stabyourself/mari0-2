gameStateManager = {}
gameStateManager.activeStates = {}
gameStateManager.reversedStates = {"mousepressed"}

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
    if inTable(gameStateManager.reversedStates, event) then
        for i = #gameStateManager.activeStates, 1, -1 do
            local v = gameStateManager.activeStates[i]

            if type(v[event]) == "function" then
                if v[event](...) then
                    break
                end
            end
        end

    else
        for _, v in ipairs(gameStateManager.activeStates) do
            if type(v[event]) == "function" then
                if v[event](...) then
                    break
                end
            end
        end

    end
end
