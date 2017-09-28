Mario = class("Mario", PhysObj)

function Mario:initialize(world, x, y)
    PhysObj.initialize(self, world, x, y)

    self.width = 12/TILESIZE
    self.height = 12/TILESIZE
    self.jumping = false
    self.falling = false
    self.ducking = false
end

function Mario:update(dt)
    self:movement(dt)

	if self.animationstate == "running" then
		--self:runanimation(dt)
	end
end

function Mario:draw()
    self.world:drawObject(self)
end

function Mario:jump()
    self.onGround = false
    self.speedY = -JUMPFORCE
end

function Mario:movement(dt)
    local friction = 0
    local acceleration = 0
    local accelerationVal = WALKACCELERATION
    local maxSpeed

    -- Normal left/right acceleration
    if keyDown("run") then
        accelerationVal = RUNACCELERATION
    end

    if (not keyDown("run") and math.abs(self.speedX) <= MAXWALKSPEED) or (keyDown("run") and math.abs(self.speedX) <= MAXRUNSPEED) then
        if keyDown("left") then
            acceleration = acceleration - accelerationVal

            if not self.onGround and self.speedX > 0 then
                acceleration = acceleration * AIRSLIDEFACTOR
            end
        end

        if keyDown("right") then
            acceleration = acceleration + accelerationVal

            if not self.onGround and self.speedX < 0 then
                acceleration = acceleration * AIRSLIDEFACTOR
            end
        end
    end

    -- Friction multiplier
    if self.jumping or self.falling then
        friction = FRICTIONAIR
    elseif math.abs(self.speedX) > MAXRUNSPEED then
        friction = SUPERFRICTION
    else
        friction = FRICTION
    end

    -- Apply friction?
    if  (not keyDown("right") and not keyDown("left")) or 
        (self.ducking and self.falling == false and self.jumping == false) or
        self.disabled or
        (not keyDown("run") and math.abs(self.speedX) > MAXWALKSPEED) or
        math.abs(self.speedX) > MAXRUNSPEED or
        ((acceleration < 0 and self.speedX > 0) or (acceleration > 0 and self.speedX < 0)) then

        if self.speedX > 0 then
            acceleration = acceleration - FRICTION
        elseif self.speedX < 0 then
            acceleration = acceleration + FRICTION
        end
    end

    -- Clamp max speeds for walk and run
    if (not keyDown("run") and math.abs(self.speedX) < MAXWALKSPEED) then
        maxSpeed = MAXWALKSPEED
    elseif (keyDown("run") and math.abs(self.speedX) < MAXRUNSPEED) then
        maxSpeed = MAXRUNSPEED
    end

    self.speedX = self.speedX + acceleration*dt

    if maxSpeed then
        if acceleration > 0 then
            self.speedX = math.min(self.speedX, maxSpeed)
        else
            self.speedX = math.max(self.speedX, -maxSpeed)
        end
    end

    -- Kill movement below a threshold
    if math.abs(self.speedX) < MINSPEED and (not keyDown("right") and not keyDown("left")) then
        self.speedX = 0
    end

    --print(acceleration, self.speedX)
end