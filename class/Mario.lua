Mario = class("Mario", PhysObj)

marioImg = love.graphics.newImage("img/mario.png")
marioQuad = {}
marioQuad.idle = {}
marioQuad.running = {}
marioQuad.sliding = {}
marioQuad.jumping = {}

for y = 1, 4 do
    marioQuad.idle[y] = love.graphics.newQuad(0, (y-1)*20, 20, 20, marioImg:getWidth(), marioImg:getHeight())

    marioQuad.running[y] = {}
    for i = 1, 3 do
        marioQuad.running[y][i] = love.graphics.newQuad(i*20, (y-1)*20, 20, 20, marioImg:getWidth(), marioImg:getHeight())
    end

    marioQuad.sliding[y] = love.graphics.newQuad(80, (y-1)*20, 20, 20, marioImg:getWidth(), marioImg:getHeight())
    marioQuad.jumping[y] = love.graphics.newQuad(100, (y-1)*20, 20, 20, marioImg:getWidth(), marioImg:getHeight())
end
    

function Mario:initialize(world, x, y)
    PhysObj.initialize(self, world, x, y)

    self.width = 12/16
    self.height = 12/16
    self.jumping = false
    self.ducking = false

    self.animationState = "idle"
    
    self.runAnimationFrame = 1
    self.runAnimationTimer = 0
    self.animationDirection = 1
    self.img = marioImg
    self.centerX = 11
    self.centerY = 11
end

function Mario:update(dt)
    -- Jump physics
    if self.jumping then
        if not keyDown("jump") or self.speedY > 0 then
            self.jumping = false
            self.gravity = GRAVITY
        end
    end

    self:animation(dt)
    self:movement(dt)

    self.quad = marioQuad[self.animationState][3]

    if self.animationState == "running" then
        self.quad = marioQuad[self.animationState][3][self.runAnimationFrame]
    end
end

function Mario:jump()
    self.onGround = false
    self.jumping = true

    self.gravity = GRAVITYJUMPING

    -- Adjust jumpforce according to speed
    local jumpforce = JUMPFORCE

    jumpforce = jumpforce + math.max(0, math.min(1, math.abs(self.speedX)/MAXRUNSPEED)) * JUMPFORCEADD

    self.speedY = -jumpforce
    self.animationState = "jumping"
    playSound(jumpSound)
end

function Mario:animation(dt)
    if self.onGround and self.speedX == 0 then
        self.animationState = "idle"
    end

    if self.onGround and ((keyDown("left") and self.speedX > 0) or (keyDown("right") and self.speedX < 0)) then
        self.animationState = "sliding"
    elseif self.onGround and self.speedX ~= 0 then
        self.animationState = "running"
    end

	if self.animationState == "running" and self.onGround then
        self.runAnimationTimer = self.runAnimationTimer + (math.abs(self.speedX)+4)/5*dt
        while self.runAnimationTimer > RUNANIMATIONTIME do
            self.runAnimationTimer = self.runAnimationTimer - RUNANIMATIONTIME
            self.runAnimationFrame = self.runAnimationFrame + 1

            if self.runAnimationFrame > 3 then
                self.runAnimationFrame = self.runAnimationFrame - 3
            end
        end
	end

    if keyDown("left") and self.onGround then
        self.animationDirection = -1
    elseif keyDown("right") and self.onGround then
        self.animationDirection = 1
    end
end

function Mario:movement(dt)
    --Todo: Don't accelerate past maxwalkspeed in air!
    --Todo: Some stuff about automatically getting maxrunspeed if on maxwalkspeed when landing
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

function Mario:ceilCollide(obj2)
    if obj2:isInstanceOf(Block) then
        -- See whether it was very close to the edge of a block next to air, in which case allow Mario to keep jumping
        -- Right side
        if self.x > obj2.x+obj2.width - JUMPLEEWAY and not game.level:getTile(obj2.blockX+1, obj2.blockY).collision then
            self.x = obj2.x+obj2.width
            self.speedX = math.max(self.speedX, 0)
            return false
        end
        
        -- Left side
        if self.x + self.width < obj2.x + JUMPLEEWAY and not game.level:getTile(obj2.blockX-1, obj2.blockY).collision then
            self.x = obj2.x-self.width
            self.speedX = math.min(self.speedX, 0)
            return false
        end

        -- See if there's a better matching block (because Mario jumped near the edge of a block)
        local toCheck = 0
        local x, y = obj2.blockX, obj2.blockY

        if self.x+self.width/2 > obj2.x+obj2.width then
            toCheck = 1
        elseif self.x+self.width/2 < obj2.x then
            toCheck = -1
        end

        if toCheck ~= 0 then
            if game.level:getTile(x+toCheck, y).collision then
                x = x + toCheck
                obj2 = game.level.blocks[x][y]
            end
        end
        
        playSound(blockSound)
        self.speedY = BLOCKHITFORCE
        
        game.level:bumpBlock(x, y)
    end
end

function Mario:startFall()
    self.animationState = "running"
end