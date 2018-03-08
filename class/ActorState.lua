ActorState = class("ActorState")

function ActorState:initialize(actor, name, func)
    self.actor = actor
    self.name = name
    self.func = func
    self.timer = 0
end

function ActorState:update(dt)
    self.timer = self.timer + dt

    self:checkExit()
end

function ActorState:switch(stateName)
    if stateName then
        assert(self.actor.states[stateName], "Tried to switch to nonexistent ActorState \"" .. stateName .. "\" on \"" .. tostring(self.actor) .. "\" and that's bad.")
        self.actor.state = ActorState:new(self.actor, stateName, self.actor.states[stateName])

        self:checkExit()
    end
end

function ActorState:checkExit()
    local newState = self.func(self.actor, self)

    if newState then
        self.actor.state = ActorState:new(self.actor, newState, self.actor.states[newState])
    end
end