local GameStateManager = class("GameStateManager")

GameStateManager.reversedEvents = {
    mousepressed = true,
    cmdpressed = true
}

function GameStateManager:initialize()
    self.activeStates = {}
end

function GameStateManager:loadState(state)
    self.activeStates = {state}
    state:load()
end

function GameStateManager:addState(state)
    table.insert(self.activeStates, state)
    state:load()
end

function GameStateManager:event(event, ...)
    prof.push(event)
    local from, to, step = 1, #self.activeStates, 1

    if self.reversedEvents[event] then
        from, to, step = to, from, -1
    end

    for i = from, to, step do
        local state = self.activeStates[i]

        if type(state[event]) == "function" then
            if state[event](state, ...) then
                break
            end
        end
    end
    prof.pop(event)
end

function GameStateManager:hasActiveState(stateClass)
    for _, state in ipairs(self.activeStates) do
        if state.class == stateClass then
            return true
        end
    end

    return false
end

return GameStateManager
