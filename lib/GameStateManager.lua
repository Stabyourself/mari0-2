local GameStateManager = class("GameStateManager")

GameStateManager.reversedStates = {"mousepressed", "keypressed"}

function GameStateManager:initialize()
    self.activeStates = {}
end

function GameStateManager:loadState(state)
    self.activeStates = {state}
    self:event("load")
end

function GameStateManager:addState(state)
    table.insert(self.activeStates, state)
    state:load()
end

function GameStateManager:event(event, ...)
    local function callStateEvent(state, event, ...)
        if type(state[event]) == "function" then
            if state[event](state, ...) then
                return true
            end
        end
    end
    
    if inITable(self.reversedStates, event) then
        for i = #self.activeStates, 1, -1 do
            local v = self.activeStates[i]

            if callStateEvent(v, event, ...) then
                break
            end
        end

    else
        for _, v in ipairs(self.activeStates) do
            if callStateEvent(v, event, ...) then
                break
            end
        end
    end
end

return GameStateManager
