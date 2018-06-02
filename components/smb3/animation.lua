local animation = class("smb3.animation")

local MAXSPEEDS = {90, 150, 210}
local ANIMATIONSPEEDS = {1/4*60, 1/3*60, 1/2*60, 1*60}

local FLYANIMATIONTIME = 4/60

local SPINFRAMETIME = 4/60

local SOMERSAULTTIME = 2/60

local SHOOTTIME = 12/60

function animation:initialize(actor, args)
    self.actor = actor
    self.args = args

    self:setup()
end

function animation:setup()
    self.actor.quadList = {}
    self.actor.frames = self.args["frames"]
    self.actor.frameCounts = {}

    for y = 1, 5 do
        self.actor.quadList[y] = {}
        local x = 0

        for _, name in ipairs(self.actor.frames) do
            local quad = love.graphics.newQuad(
                x*self.actor.quadWidth,
                (y-1)*self.actor.quadHeight,
                self.actor.quadWidth,
                self.actor.quadHeight,
                self.actor.img:getWidth(),
                self.actor.img:getHeight())

            if self.actor.quadList[y][name] then
                if type(self.actor.quadList[y][name]) ~= "table" then
                    self.actor.quadList[y][name] = {self.actor.quadList[y][name]}
                end

                table.insert(self.actor.quadList[y][name], quad)
                self.actor.frameCounts[name] = self.actor.frameCounts[name] + 1
            else
                self.actor.quadList[y][name] = quad
                self.actor.frameCounts[name] = 1
            end

            x = x + 1
        end
    end

    self.actor.quad = self.actor.quadList[3].idle
end

function animation:postUpdate(dt)
    if self.actor.hasPortalGun then -- look towards portalGunAngle
        if math.abs(self.actor.portalGunAngle-self.actor.visAngle) <= math.pi*.5 then
            self.actor.animationDirection = 1
        else
            self.actor.animationDirection = -1
        end

    else -- look towards last pressed direction
        if cmdDown("left") then
            self.actor.animationDirection = -1
        elseif cmdDown("right") then
            self.actor.animationDirection = 1
        end
    end

    local frame = false

    if  self.actor.spinning and
        (not self.actor.starred or (self.actor.state.name ~= "jump" and self.actor.state.name ~= "fall"))  then
        if self.actor.onGround then
            self.actor.animationState = "spin"
        else
            self.actor.animationState = "spinAir"
        end

        self.actor.animationDirection = self.actor.spinDirection

        -- calculate spin frame from spinTimer
        frame = 1+math.floor(math.fmod(self.actor.spinTimer, self.actor.frameCounts.spin*SPINFRAMETIME)/SPINFRAMETIME)

    elseif  self.actor.shooting and
            (not self.actor.starred or (self.actor.state.name ~= "jump" and self.actor.state.name ~= "fall")) then
        if self.actor.onGround then
            self.actor.animationState = "shoot"
        else
            self.actor.animationState = "shootAir"
        end

        frame = math.ceil(self.actor.shootTimer/SHOOTTIME*self.actor.frameCounts.shoot)

    elseif self.actor.ducking then
        self.actor.animationState = "duck"

    elseif not self.actor.state or self.actor.state.name == "idle" then
        self.actor.animationState = "idle"

    elseif self.actor.state.name == "skid" then
        self.actor.animationState = "skid"

    elseif self.actor.state.name == "stop" or self.actor.state.name == "run" then
        if math.abs(self.actor.speed[1]) >= MAXSPEEDS[3] then
            self.actor.animationState = "sprint"
        else
            self.actor.animationState = "run"
        end

    elseif  self.actor.flying and
            (self.actor.state.name == "jump" or self.actor.state.name == "fly" or self.actor.state.name == "fall") then
        self.actor.animationState = "fly"

    elseif self.actor.state.name == "buttSlide" then
        self.actor.animationState = "buttSlide"

    elseif self.actor.starred and self.actor.frameCounts.somerSault then
        self.actor.animationState = "somerSault"

    elseif self.actor.state.name == "float" then
        self.actor.animationState = "float"

    elseif self.actor.state.name == "jump" or self.actor.state.name == "fall" then
        if not self.actor.quadList.canFly and self.actor.pMeter == VAR("pMeterTicks") then
            self.actor.animationState = "fly"
        elseif (not self.actor.quadList.canFly and self.actor.maxSpeedJump == MAXSPEEDS[3]) or self.actor.flying then
            self.actor.animationState = "fly"
        else
            if self.actor.speed[2] < 0 then
                self.actor.animationState = "jump"
            else
                self.actor.animationState = "fall"
            end
        end

    end


    -- Running animation
    if (self.actor.animationState == "run" or self.actor.animationState == "sprint") then
        local animationspeed

        if math.abs(self.actor.speed[1]) >= MAXSPEEDS[3] then -- sprint speed
            animationspeed = ANIMATIONSPEEDS[4]
        elseif math.abs(self.actor.speed[1]) > MAXSPEEDS[2] then -- sprint speed
            animationspeed = ANIMATIONSPEEDS[3]
        elseif math.abs(self.actor.speed[1]) > MAXSPEEDS[1] then -- sprint speed
            animationspeed = ANIMATIONSPEEDS[2]
        else
            animationspeed = ANIMATIONSPEEDS[1]
        end

        self.actor.runAnimationTimer = self.actor.runAnimationTimer + animationspeed*dt

        while self.actor.runAnimationTimer > 1 do
            self.actor.runAnimationTimer = self.actor.runAnimationTimer - 1
            self.actor.runAnimationFrame = self.actor.runAnimationFrame + 1

            local runFrames = self.actor.frameCounts.run

            if self.actor.runAnimationFrame > runFrames then
                self.actor.runAnimationFrame = self.actor.runAnimationFrame - runFrames
            end
        end

        frame = self.actor.runAnimationFrame
    end

    -- Flying animation
    if self.actor.animationState == "fly" then
        local flyFrames = self.actor.frameCounts.fly

        if flyFrames > 1 then
            if self.actor.state.name == "fall" then
                self.actor.flyAnimationFrame = 2
            else
                self.actor.flyAnimationTimer = self.actor.flyAnimationTimer + dt
                while self.actor.flyAnimationTimer > FLYANIMATIONTIME do
                    self.actor.flyAnimationTimer = self.actor.flyAnimationTimer - FLYANIMATIONTIME
                    self.actor.flyAnimationFrame = self.actor.flyAnimationFrame + 1

                    if self.actor.flyAnimationFrame > flyFrames then
                        self.actor.flyAnimationFrame = flyFrames -- don't reset to the start
                    end
                end
            end

            frame = self.actor.flyAnimationFrame
        end
    end

    -- Float animation
    if self.actor.animationState == "float" then
        self.actor.floatAnimationTimer = self.actor.floatAnimationTimer + dt
        while self.actor.floatAnimationTimer > FLYANIMATIONTIME do
            self.actor.floatAnimationTimer = self.actor.floatAnimationTimer - FLYANIMATIONTIME
            self.actor.floatAnimationFrame = self.actor.floatAnimationFrame + 1

            local floatFrames = self.actor.frameCounts.float
            if self.actor.floatAnimationFrame > floatFrames then
                self.actor.floatAnimationFrame = floatFrames -- don't reset to the start
            end
        end

        frame = self.actor.floatAnimationFrame
    end

    -- Somersault animation
    if  self.actor.starred and
        (self.actor.state.name == "jump" or self.actor.state.name == "fall" or self.actor.state.name == "float") then
        local somersaultFrames = self.actor.frameCounts.somerSault

        self.actor.somerSaultFrameTimer = self.actor.somerSaultFrameTimer + dt

        while self.actor.somerSaultFrameTimer > SOMERSAULTTIME do
            self.actor.somerSaultFrameTimer = self.actor.somerSaultFrameTimer - SOMERSAULTTIME

            self.actor.somerSaultFrame = self.actor.somerSaultFrame + 1
            if self.actor.somerSaultFrame > somersaultFrames then
                self.actor.somerSaultFrame = 1
            end
        end

        frame = self.actor.somerSaultFrame
    end

    -- Make sure to properly use the tables if it's an animationState with frames
    if frame then
        self.actor.quad = self.actor.quadList[getAngleFrame(self.actor)][self.actor.animationState][frame]
    else
        self.actor.quad = self.actor.quadList[getAngleFrame(self.actor)][self.actor.animationState]
    end

    assert(type(self.actor.quad) == "userdata", string.format(
        [[The state "%s" on actorTemplate %s seems to not be have a quad set up correctly. (attempted frame was "%s")]],
        self.actor.animationState,
        self.actor.actorTemplate.name,
        tostring(frame)))
end

function getAngleFrame(actor)
    if not actor.hasPortalGun then
        return 5
    end

    local angle = actor.portalGunAngle-actor.visAngle

    if angle > math.pi*.5 then
        angle = math.pi - angle
    elseif angle < -math.pi*.5 then
        angle = -math.pi - angle
    end

    if angle < -math.pi*0.375 then
        return 1
    elseif angle < -math.pi*0.125 then
        return 2
    elseif angle < math.pi*0.125  then
        return 3
    elseif angle < math.pi*0.375 then
        return 4
    else -- Downward frame looks dumb
        return 4
    end
end

return animation
