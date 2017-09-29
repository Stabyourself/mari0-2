Enemy = class("Enemy", PhysObj)

function Enemy:initialize(world, x, y, json, img, quad)
    self.world = world
    self.x = x
    self.y = y
    self.json = json
    self.img = img
    self.quadList = quad
    

    PhysObj.initialize(self, world, x-json.width/2-.5, y-json.height)

    for i, v in pairs(json) do
        self[i] = v
    end
    
    -- Set up animation
    self.animationDirection = -1

    if self.animation == "frames" then
        self.frameTimer = 0
        self.frame = 1
        self.quad = quad[self.frame]
    end

    -- Set up movement
    if self.movement == "truffleshuffle" then
        self.shuffleDir = -1
    end
end

function Enemy:update(dt)
    self:animate(dt)
    self:move(dt)
end

function Enemy:animate(dt)
    if self.animation == "frames" then
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

function Enemy:move(dt)
    if self.movement == "truffleshuffle" then
        self.speedX = self.speed*self.shuffleDir
    end
end

function Enemy:leftCollide(obj2)
    if self.movement == "truffleshuffle" and self.shuffleDir == -1 then
        self.shuffleDir = -self.shuffleDir
    end
end

function Enemy:rightCollide(obj2)
    if self.movement == "truffleshuffle" and self.shuffleDir == 1 then
        self.shuffleDir = -self.shuffleDir
    end
end
