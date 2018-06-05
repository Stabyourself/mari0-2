local wakesUp = class("misc.wakesUp", Component)

wakesUp.argList = {
    {"time", "number", 6.9},
    {"onlyWhen", "string|falseable", false},
}

function wakesUp:initialize(actor, args)
    Component.initialize(self, actor, args)

    self.timer = self.time
end

function wakesUp:update(dt)
    local running = true

    if self.onlyWhen == "stopped" and self.actor.speed[1] ~= 0 then
        running = false
    end

    if running then
        self.timer = self.timer - dt

        if self.timer <= 0 then
            self.actor:event("wakeUp", dt)
        end
    else
        self.timer = self.time
    end
end

return wakesUp
