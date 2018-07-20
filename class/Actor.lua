local Actor = class("Actor", Physics3.PhysObj)
local ActorState = require "class.ActorState"
local ActorEvent = require "class.ActorEvent"

function Actor:__tostring()
    return string.format("Actor (%s)", self.actorTemplate.name)
end

function Actor:initialize(world, x, y, actorTemplate)
    self.actorTemplate = actorTemplate

    local width = self.actorTemplate.width
    local height = self.actorTemplate.height

    Physics3.PhysObj.initialize(self, world, x-width/2, y-height, width, height)

    self.actorEvent = {}

    self.debug = {
        actorState = VAR("debug").actorState,
        hitBox = VAR("debug").actorHitBox,
        components = VAR("debug").actorComponents,
    }

    self.animationDirection = -1

    self.caching = {
        "x",
        "y",
        "onGround",
        "speed"
    }

    self.cache = {speed={}}

    self:loadActorTemplate(self.actorTemplate)
end

function Actor:event(eventName, dt, ...)
    if not self.actorEvent[eventName] then
        self.actorEvent[eventName] = ActorEvent:new(self, eventName)
    else
        self.actorEvent[eventName]:clear(eventName)
    end

    for _, component in ipairs(self.components) do
        if component[eventName] then

            prof.push(tostring(component.class) .. " " .. eventName)
            if eventName == "enterWater" then
                print(component, eventName)
            end
            component[eventName](component, dt, self.actorEvent[eventName], ...)
            prof.pop()
        end
    end

    self.actorEvent[eventName]:finish()

    return self.actorEvent[eventName].returns
end

function Actor:update(dt)
    if self.state then
        self.state:update(dt, self)
    end

    -- Cache certain fields so that we don't get weird race conditions between components
    for _, field in ipairs(self.caching) do
        if type(self[field]) == "table" then
            for i, v in ipairs(self[field]) do
                self.cache[field][i] = v
            end
        else
            self.cache[field] = self[field]
        end
    end

    self:event("update", dt)
end

function Actor:postUpdate(dt)
    self:event("postUpdate", dt)
end

function Actor:draw()
    self:event("draw")
    self:debugDraw()
end

function Actor:registerState(name, func)
    self.states[name] = func
end

function Actor:addComponent(component, args)
    if type(component) == "string" then
        component = components[component]
    end

    table.insert(self.components, component:new(self, args))
end

function Actor:removeComponent(component)
    if type(component) == "string" then
        component = components[component]
    end

    for i = #self.components, 1, -1 do
        if self.components[i].class == component then
            table.remove(self.components, i)
        end
    end
end

function Actor:hasComponent(component)
    if type(component) == "string" then
        component = components[component]
    end

    for i = #self.components, 1, -1 do
        if self.components[i].class == component then
            return self.components[i]
        end
    end

    return false
end

function Actor:loadActorTemplate(actorTemplate)
    self.actorTemplate = actorTemplate

    self:changeSize(self.actorTemplate.width, self.actorTemplate.height)

    self.img = self.actorTemplate.img

    self.quadWidth = self.actorTemplate.quadWidth
    self.quadHeight = self.actorTemplate.quadHeight

    self.centerX = self.actorTemplate.centerX
    self.centerY = self.actorTemplate.centerY

    self.quad = nil
    self.quads = self.actorTemplate.quads

    self.state = nil
    self.states = {}

    self.components = {}
    for name, args in pairs(self.actorTemplate.components) do
        assert(components[name],
            string.format(
                "Unable to load component \"%s\" requested by actorTemplate \"%s\".",
                name,
                actorTemplate.name
            )
        )

        self:addComponent(components[name], args)
    end
end

function Actor:topCollision(obj2)
    self:event("topCollision", 0, obj2)
end

function Actor:bottomCollision(obj2)
    return self:event("bottomCollision", 0, obj2)
end

function Actor:leftCollision(obj2)
    return self:event("leftCollision", 0, obj2)
end

function Actor:rightCollision(obj2)
    return self:event("rightCollision", 0, obj2)
end

function Actor:startFall()
    self:event("startFall")
end

function Actor:portalled()
    self:event("portalled")
    Physics3.PhysObj.portalled(self)
end

function Actor:friction(dt, friction, min)
    if self.speed[1] > (min or 0) then
        self.speed[1] = math.max(min or 0, self.speed[1] - friction*dt)
    elseif self.speed[1] < -(min or 0) then
        self.speed[1] = math.min(-(min or 0), self.speed[1] + friction*dt)
    end
end

function Actor:accelerateTo(dt, target, acceleration)
    if self.speed[1] > target then
        self.speed[1] = math.max(target, self.speed[1] - acceleration*dt)
    elseif self.speed[1] < target then
        self.speed[1] = math.min(target, self.speed[1] + acceleration*dt)
    end
end

function Actor:switchState(stateName)
    if stateName then
        assert(self.states[stateName], string.format(
            "Tried to switch to nonexistent ActorState \"%s\" on %s.",
            stateName,
            self.actorTemplate.name))
        self.state = ActorState:new(self, stateName, self.states[stateName])

        self.state:checkExit()
    end
end

function Actor:debugDraw()
    love.graphics.setColor(1, 1, 1)
    if self.debug.actorState then
        local s = "nil"

        if self.state then
            s = self.state.name
        end

        love.graphics.printf(s, self.x+self.width/2-500, self.y+self.height+2, 1000, "center")
    end

    if self.debug.hitBox then
        Physics3.PhysObj.debugDraw(self)
    end

    if self.debug.components then
        love.graphics.scale(1/VAR("scale"), 1/VAR("scale"))
        local font = love.graphics.getFont()

        for i, component in ipairs(self.components) do
            love.graphics.print(
                string.sub(tostring(component), 19),
                (self.x+self.width+2)*VAR("scale"),
                (self.y+self.height)*VAR("scale") - 9 - #self.components*10+i*10)
        end

        love.graphics.scale(VAR("scale"), VAR("scale"))
        love.graphics.setFont(font)
    end
end

return Actor
