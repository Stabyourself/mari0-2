-- Game State thing for Mari0 2. Feel free to use it, MIT License

local GameStateManager3 = class("GameStateManager3")

GameStateManager3.reversedEvents = {
    mousepressed = true,
    cmdpressed = true
}

function GameStateManager3:initialize()
    self.activeStates = {}
end

function GameStateManager3:loadState(state)
    self.activeStates = {state}
    state:load()
end

function GameStateManager3:addState(state)
    table.insert(self.activeStates, state)
    state:load()
end

function GameStateManager3:event(event, ...)
    prof.push(event)
    local from, to, step = 1, #self.activeStates, 1

    if self.reversedEvents[event] then
        from, to, step = to, from, -1
    end

    for i = from, to, step do
        local state = self.activeStates[i]

        if type(state[event]) == "function" then
            prof.push(state.class.name)

            if state[event](state, ...) then
                prof.pop(state.class.name)
                break
            end

            prof.pop(state.class.name)
        end
    end
    prof.pop(event)
end

function GameStateManager3:hasActiveState(stateClass)
    for _, state in ipairs(self.activeStates) do
        if state.class == stateClass then
            return true
        end
    end

    return false
end

return GameStateManager3
