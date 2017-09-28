Mario = class("Mario", PhysObj)

marioImg = love.graphics.newImage("img/mario.png")
marioQuad = {}
marioQuad.idle = {}

for y = 1, 4 do
    marioQuad.idle[y] = love.graphics.newQuad(0, (y-1)*20, 20, 20, marioImg:getWidth(), marioImg:getHeight())
end
    

function Mario:initialize(world, x, y)
    PhysObj.initialize(self, world, x, y)

    self.width = 12/TILESIZE
    self.height = 12/TILESIZE
    self.jumping = false
    self.ducking = false
end

function Mario:update(dt)
    self:movement(dt)

    --Jump physics
    if self.jumping then
        if not keyDown("jump") or self.speedY > 0 then
            self.jumping = false
            self.gravity = GRAVITY
        end
    end

	if self.animationstate == "running" then
		--self:runanimation(dt)
	end
end

function Mario:draw()
    worldDraw(marioImg, marioQuad.idle[3], self.x+self.width/2, self.y+self.height-6/TILESIZE, self.r, 1, 1, 11, 11)
    --self.world:drawObject(self)
end

function Mario:jump()
    self.onGround = false
    self.jumping = true

    self.gravity = GRAVITYJUMPING

    -- Adjust jumpforce according to speed
    local jumpforce = JUMPFORCE

    jumpforce = jumpforce + math.max(0, math.min(1, math.abs(self.speedX)/MAXRUNSPEED)) * JUMPFORCEADD

    self.speedY = -jumpforce
end

function Mario:movement(dt)
    local acceleration = 0

    -- Normal left/right acceleration

    if (not keyDown("run") and math.abs(self.speedX) <= MAXWALKSPEED) or (keyDown("run") and math.abs(self.speedX) <= MAXRUNSPEED) then
        local accelerationVal = WALKACCELERATION
        if keyDown("run") then
            accelerationVal = RUNACCELERATION
        end

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

    -- Apply friction?
    if  (not keyDown("right") and not keyDown("left")) or 
        (self.ducking and self.onGround) or
        self.disabled or
        (not keyDown("run") and math.abs(self.speedX) > MAXWALKSPEED) or
        math.abs(self.speedX) > MAXRUNSPEED or
        ((acceleration < 0 and self.speedX > 0) or (acceleration > 0 and self.speedX < 0)) then

        -- Friction multiplier
        local friction = FRICTION
        if not self.onGround then
            friction = FRICTIONAIR
        elseif math.abs(self.speedX) > MAXRUNSPEED then
            friction = SUPERFRICTION
        end

        if self.speedX > 0 then
            acceleration = acceleration - FRICTION
        elseif self.speedX < 0 then
            acceleration = acceleration + FRICTION
        end
    end

    -- Clamp max speeds for walk and run
    local maxSpeed

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
end