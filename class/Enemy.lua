Enemy = class("Enemy", fissix.PhysObj)

function Enemy:initialize(world, x, y, json, img, quad)
    self.json = json
    fissix.PhysObj.initialize(self, world, x-json.width/2, y-json.height, json.width, json.height)

    self.img = img
    self.quadList = quad
    
    self.autoRemove = true

    for i, v in pairs(json) do
        self[i] = v
    end
    
    -- Set up animation
    self.animationDirection = -1

    if self.animationType == "frames" then
        self.frameTimer = 0
        self.frame = 1
        self.quad = quad[self.frame]
    end

    -- Set up movement
    if self.movementType == "truffleshuffle" then
        self.shuffleDir = -1
    end
    
    self.sizeX = 16
    self.sizeY = 16
end

function Enemy:update(dt)
    self:animation(dt)
    self:movement(dt)
    
    if CHEAT("spinnyMario") then
        self.r = self.r + self.speedX*dt*0.1
        self:unRotate(0)
    else
        self.r = self.r + self.speedX*dt*0.1
        self:unRotate(dt)
    end

    if self.autoRemove and (self.x+self.width < game.level.camera.x-1 or self.y > HEIGHT+1) then
        return true
    end
end

function Enemy:animation(dt)
    if self.animationType == "frames" then
        self.frameTimer = self.frameTimer + dt

        while self.frameTimer > self.frameTime do
            self.frameTimer = self.frameTimer - self.frameTime
            self.frame = self.frame + 1

            if self.frame > self.frames then
                self.frame = 1
            end

            self.quad = self.quadList[self.frame]
        end
    end
end

function Enemy:movement(dt)
    if self.movementType == "truffleshuffle" then
        self.speedX = self.speed*self.shuffleDir
    end
end

function Enemy:leftCollision(obj2)
    if self.movementType == "truffleshuffle" and self.shuffleDir == -1 then
        self.shuffleDir = -self.shuffleDir
    end
end

function Enemy:rightCollision(obj2)
    if self.movementType == "truffleshuffle" and self.shuffleDir == 1 then
        self.shuffleDir = -self.shuffleDir
    end
end

function Enemy:stomp()

end
