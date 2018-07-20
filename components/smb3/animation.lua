local Component = require "class.Component"
local animation = class("smb3.animation", Component)

animation.argList = {
    {"frames", "required|table"},
}

local MAXSPEEDS = {90, 150, 210}

local FLYANIMATIONTIME = 4/60
local SPINFRAMETIME = 4/60
local SOMERSAULTTIME = 2/60
local SHOOTTIME = 12/60

local function assignQuad(actor, x, y, name, angle)
    local quad = love.graphics.newQuad(
        (x-1)*actor.quadWidth,
        (y-1)*actor.quadHeight,
        actor.quadWidth,
        actor.quadHeight,
        actor.img:getWidth(),
        actor.img:getHeight())

    if actor.quadList[name][angle] then
        if type(actor.quadList[name][angle]) ~= "table" then
            actor.quadList[name][angle] = {actor.quadList[name][angle]}
        end

        table.insert(actor.quadList[name][angle], quad)
    else
        actor.quadList[name][angle] = quad
    end
end

function animation:initialize(actor, args)
    Component.initialize(self, actor, args)

    self.actor.quadList = {}
    self.actor.frameCounts = {}

    self.actor.runAnimationFrame = 1
    self.actor.runAnimationTimer = 0

    self.actor.somerSaultFrame = 2
    self.actor.somerSaultFrameTimer = 0

    self.actor.swimAnimationFrame = 1
    self.actor.swimAnimationTimer = 0

    local lineBreak = actor.img:getWidth()/actor.quadWidth

    for _, frameTable in ipairs(self.frames) do
        local x = 1
        local y = 1

        for _, name in ipairs(frameTable.names) do
            if not self.actor.quadList[name] then
                self.actor.quadList[name] = {}
            end

            local noGunFrameY

            if frameTable.type == "8-dir" then
                for angleY = 1, 8 do
                    assignQuad(self.actor, frameTable.x+x-1, frameTable.y+y+angleY-2, name, angleY)
                end

                noGunFrameY = 9

            elseif frameTable.type == "1-dir" then
                assignQuad(self.actor, frameTable.x+x-1, frameTable.y+y-1, name, 1)

                for y = 2, 8 do
                    self.actor.quadList[name][y] = self.actor.quadList[name][1]
                end

                noGunFrameY = 2
            end

            if frameTable.plusNoGun then
                assignQuad(self.actor, frameTable.x+x-1, frameTable.y+(noGunFrameY-1)*y, name, "noGun")
            end

            if not actor.frameCounts[name] then
                actor.frameCounts[name] = 0
            end

            actor.frameCounts[name] = actor.frameCounts[name] + 1

            x = x + 1

            if x > lineBreak then
                x = frameTable.x
                y = y + noGunFrameY
            end
        end
    end

    self.actor.quad = self.actor.quadList.idle[3]
end

function animation:postUpdate(dt)
    -- if self.actor.hasPortalGun then -- look towards portalGunAngle
    --     if math.abs(self.actor.portalGunAngle-self.actor.angle) <= math.pi*.5 then
    --         self.actor.animationDirection = 1
    --     else
    --         self.actor.animationDirection = -1
    --     end

    -- else -- look towards last pressed direction
        if controls3.cmdDown("left") then
            self.actor.animationDirection = -1
        elseif controls3.cmdDown("right") then
            self.actor.animationDirection = 1
        end
    -- end

    local frame = false

    self.actor.animationState = "idle"

    if  self.actor.spinning and
        (not self.actor.starred or (self.actor.state.name ~= "jumping" and self.actor.state.name ~= "falling"))  then
        local frameCount

        if self.actor.onGround then
            self.actor.animationState = "spin"
            frameCount = self.actor.frameCounts.spin
        else
            self.actor.animationState = "spinAir"
            frameCount = self.actor.frameCounts.spinAir
        end

        self.actor.animationDirection = self.actor.spinDirection

        -- calculate spin frame from spinTimer
        frame = 1+math.floor(math.fmod(self.actor.spinTimer, frameCount*SPINFRAMETIME)/SPINFRAMETIME)

    elseif  self.actor.shooting and
            (not self.actor.starred or (self.actor.state.name ~= "jumping" and self.actor.state.name ~= "falling")) then
        if self.actor.onGround then
            self.actor.animationState = "shoot"
        else
            self.actor.animationState = "shootAir"
        end

        frame = math.ceil(self.actor.shootTimer/SHOOTTIME*self.actor.frameCounts.shoot)

    elseif self.actor.ducking then
        self.actor.animationState = "duck"

    elseif self.actor.state.name == "grounded" then
        if self.actor.speed[1] == 0 then
            self.actor.animationState = "idle"

        elseif self.actor.speed[1] > 0 then
            if controls3.cmdDown("left") and not self.actor.underWater then
                self.actor.animationState = "skid"
            else
                if math.abs(self.actor.speed[1]) >= MAXSPEEDS[3] then
                    self.actor.animationState = "sprint"
                else
                    self.actor.animationState = "run"
                end
            end

        elseif self.actor.speed[1] < 0 then
            if controls3.cmdDown("right") and not self.actor.underWater then
                self.actor.animationState = "skid"
            else
                if math.abs(self.actor.speed[1]) >= MAXSPEEDS[3] then
                    self.actor.animationState = "sprint"
                else
                    self.actor.animationState = "run"
                end
            end
        end

    elseif  self.actor.flying and
            (self.actor.state.name == "jumping" or self.actor.state.name == "flying" or self.actor.state.name == "falling") then
        self.actor.animationState = "fly"

    elseif self.actor.state.name == "buttSliding" then
        self.actor.animationState = "buttSlide"

    elseif self.actor.starred and self.actor.frameCounts.somerSault then
        self.actor.animationState = "somerSault"

    elseif self.actor.state.name == "floating" then
        self.actor.animationState = "float"

    elseif self.actor.state.name == "jumping" or self.actor.state.name == "falling" then
        if not self.actor.quadList.canFly and self.actor.pMeter == VAR("pMeterTicks") then -- todo wtf
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

    elseif self.actor.state.name == "swimming" then
        local frameCount

        if self.actor.upSwimCycles > 0 then
            self.actor.animationState = "swimUp"
            frameCount = self.actor.frameCounts.swimUp
        else
            self.actor.animationState = "swim"
            frameCount = self.actor.frameCounts.swim
        end

        local animationSpeed
        if self.actor.speed[1] == 0 and self.actor.animationState == "swim" then
            animationSpeed = 16/60
        else
            animationSpeed = (7-math.min(math.floor(math.abs(self.actor.speed[1])/60*16/8), 6))/60 -- frametime is between 1 and 7 frames
        end

        self.actor.swimAnimationTimer = self.actor.swimAnimationTimer + dt

        while self.actor.swimAnimationTimer > animationSpeed do
            self.actor.swimAnimationTimer = self.actor.swimAnimationTimer - animationSpeed
            self.actor.swimAnimationFrame = self.actor.swimAnimationFrame + 1

            if self.actor.swimAnimationFrame > frameCount then
                self.actor.swimAnimationFrame = self.actor.swimAnimationFrame - frameCount

                if self.actor.animationState == "swimUp" then
                    self.actor.upSwimCycles = math.max(0, self.actor.upSwimCycles - 1)
                end
            end
        end

        frame = self.actor.swimAnimationFrame
    end


    -- Running animation
    if (self.actor.animationState == "run" or self.actor.animationState == "sprint") then
        local animationSpeed = (7-math.min(math.floor(math.abs(self.actor.speed[1])/60*16/8), 6))/60 -- frametime is between 1 and 7 frames

        self.actor.runAnimationTimer = self.actor.runAnimationTimer + dt

        while self.actor.runAnimationTimer > animationSpeed do
            self.actor.runAnimationTimer = self.actor.runAnimationTimer - animationSpeed
            self.actor.runAnimationFrame = self.actor.runAnimationFrame + 1

            if self.actor.runAnimationFrame > self.actor.frameCounts.run then
                self.actor.runAnimationFrame = self.actor.runAnimationFrame - self.actor.frameCounts.run
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
        self.actor.quad = self.actor.quadList[self.actor.animationState][getAngleFrame(self.actor)][frame]
    else
        self.actor.quad = self.actor.quadList[self.actor.animationState][getAngleFrame(self.actor)]
    end

    assert(type(self.actor.quad) == "userdata", string.format(
        [[The state "%s" on actorTemplate %s seems to not be have a quad set up correctly. (attempted frame was "%s")]],
        self.actor.animationState,
        self.actor.actorTemplate.name,
        tostring(frame)))
end

function getAngleFrame(actor)
    if not actor.hasPortalGun then
        return "noGun"
    end

    local angle = actor.portalGunAngle-actor.angle

    if actor.animationDirection == -1 then
        angle = -angle + math.pi
        angle = normalizeAngle(angle)
    end

    for i = 0, 8 do
        if angle < -math.pi*(0.875-i*0.25) then
            local out = 7+i

            if out > 8 then
                out = out - 8
            end

            return out
        end
    end
end

return animation
