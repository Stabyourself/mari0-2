local ActorEvent = class("ActorEvent")

function ActorEvent:initialize(actor, name)
    self.actor = actor
    self.name = name
    self.binds = {}
    self.values = {}
end

function ActorEvent:clear(name)
    self.name = name
    clearTable(self.binds)
    for i, _ in pairs(self.values) do
        clearTable(self.values[i])
    end
    self.returns = nil
end

function ActorEvent:finish()
    -- Fire any delayed code
    self:fire("after")

    -- Set any values that were put on the prioritized stack
    for i, v in pairs(self.values) do
        local topPriority = -math.huge
        local value = nil

        for _, w in ipairs(v) do
            if w.priority > topPriority then
                topPriority = w.priority
                value = w.value
            end
        end

        if value then
            self.actor[i] = value
        end
    end
end

function ActorEvent:bind(name, func)
    if not self.binds[name] then
        self.binds[name] = {}
    end

    table.insert(self.binds[name], func)
end

function ActorEvent:fire(name)
    if self.binds[name] then
        for _, func in ipairs(self.binds[name]) do
            func(self.actor)
        end
    end
end

function ActorEvent:setValue(name, value, priority)
    if not self.values[name] then
        self.values[name] = {}
    end

    table.insert(self.values[name], {value=value, priority=priority or 1}) -- todo: generates trash
end

return ActorEvent
