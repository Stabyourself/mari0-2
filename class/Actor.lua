Actor = class("Actor", Physics3.PhysObj)

function Actor:initialize(world, x, y, actorTemplate)
    self.actorTemplate = actorTemplate

    local width = self.actorTemplate.width
    local height = self.actorTemplate.height
    
    Physics3.PhysObj.initialize(self, world, x-width/2, y-height, width, height)
    
    self.states = {}

    self.components = {}
    for name, args in pairs(self.actorTemplate.components) do
        assert(components[name], string.format("Unable to load component \"%s\" requested by actorTemplate \"%s\".", name, actorTemplate.name))

        self:addComponent(components[name], args)
    end

    self.debug = {
        actorState = VAR("debug").actorState,
        hitBox = VAR("debug").actorHitBox,
        components = VAR("debug").actorComponents,
    }
end

function Actor:event(eventName, dt)
    local actorEvent = ActorEvent:new(self, eventName)

    for _, component in ipairs(self.components) do
        if component.code[eventName] then
            component.code[eventName](self, dt, actorEvent, component.args)
        end
    end

    actorEvent:finish()
end

function Actor:update(dt)
    if self.state then
        self.state:update(dt, self)
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
    table.insert(self.components, {name = component.name, code=component.code, args=args})

    if component.code.setup then
        local actorEvent = ActorEvent:new(self, "setup")

        component.code.setup(self, dt, actorEvent, args)

        actorEvent:finish()
    end
end

function Actor:ceilCollision(obj2)
    if obj2:isInstanceOf(Block) then
        -- See if there's a better matching block (because Actor jumped near the edge of a block)
        -- local toCheck = 0
        -- local x, y = obj2.blockX, obj2.blockY

        -- if self.x+self.width/2 > obj2.x+obj2.width then
        --     toCheck = 1
        -- elseif self.x+self.width/2 < obj2.x then
        --     toCheck = -1
        -- end

        -- if toCheck ~= 0 then
        --     if game.level:getTile(x+toCheck, y).collision then
        --         x = x + toCheck
        --     end
        -- end

        -- Todo: Do this
    end
        
    -- self.speed[2] = VAR("blockHitForce")
    
    -- game.level:bumpBlock(x, y)
    self:event("ceilCollision")
end

function Actor:bottomCollision(obj2)
    -- if obj2 and obj2.stompable then
    --     obj2:stomp()
    --     self.speed[2] = -getRequiredSpeed(VAR("enemyBounceHeight"))
    -- end

    self:event("bottomCollision")
end

function Actor:leftCollision(obj2)
    self:event("leftCollision")
end

function Actor:rightCollision(obj2)
    self:event("rightCollision")
end

function Actor:startFall()
    self:event("startFall")
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
        assert(self.states[stateName], string.format("Tried to switch to nonexistent ActorState \"%s\" on %s.", stateName, self.actorTemplate.name))
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
        local mx, my = self.world:mouseToWorld()

        love.graphics.scale(1/VAR("scale"), 1/VAR("scale"))
        local font = love.graphics.getFont()

        for i, component in ipairs(self.components) do
            love.graphics.print(component.name, (self.x+self.width+2)*VAR("scale"), (self.y+self.height)*VAR("scale") - 9 - #self.components*10+i*10)
        end

        love.graphics.scale(VAR("scale"), VAR("scale"))
        love.graphics.setFont(font)
    end
end
