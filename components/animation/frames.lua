local frames = class("animation.frames", Component)

frames.argList = {
    {"frames", "required|table"},
    {"times", "table", {0.2}},
    {"dontAnimateWhenStill", "boolean", false},
    {"useFrameWhenStill", "number|falseable", false},
}

function frames:initialize(actor, args)
    Component.initialize(self, actor, args)

    self.frame = 1
    self.frameTimer = 0

    self.actor.quad = self.actor.quads[self.frames[1]]
end

local function getDelay(times, frame)
    return times[(frame-1)%#times + 1]
end

function frames:update(dt)
    if not self.dontAnimateWhenStill or self.actor.speed[1] ~= 0 then
        self.frameTimer = self.frameTimer + dt

        while self.frameTimer > getDelay(self.times, self.frame) do
            self.frameTimer = self.frameTimer - getDelay(self.times, self.frame)

            self.frame = self.frame + 1

            if self.frame > #self.frames then
                self.frame = 1
            end

            self.actor.quad = self.actor.quads[self.frames[self.frame]]
        end
    end

    if self.useFrameWhenStill and self.actor.speed[1] == 0 then
        self.actor.quad = self.actor.quads[self.useFrameWhenStill]
    end
end

return frames