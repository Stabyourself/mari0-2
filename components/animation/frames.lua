local frames = class("animation.frames")

local FRAMETIMES = {0.2}

function frames:initialize(actor, args)
    self.actor = actor
    self.args = args

    self:setup()
end

function frames:setup()
    self.frame = 1
    self.frameLookup = self.args.frames
    self.frameTimes = self.args.times or FRAMETIMES
    self.frameTimer = 0

    self.actor.quad = self.actor.quads[self.frameLookup[1]]
end

local function getDelay(frameTimes, frame)
    return frameTimes[(frame-1)%#frameTimes + 1]
end

function frames:update(dt)
    if not self.args.dontAnimateWhenStill or self.actor.speed[1] ~= 0 then
        self.frameTimer = self.frameTimer + dt

        while self.frameTimer > getDelay(self.frameTimes, self.frame) do
            self.frameTimer = self.frameTimer - getDelay(self.frameTimes, self.frame)

            self.frame = self.frame + 1

            if self.frame > #self.frameLookup then
                self.frame = 1
            end

            self.actor.quad = self.actor.quads[self.frameLookup[self.frame]]
        end
    end
end

return frames