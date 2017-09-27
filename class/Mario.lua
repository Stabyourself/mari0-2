Mario = class("Mario", PhysObj)

function Mario:initialize(world, x, y)
    PhysObj.initialize(self, world, x, y)

    self.width = 12/TILESIZE
    self.height = 12/TILESIZE
end

function Mario:update(dt)
    if love.keyboard.isDown(CONTROLS[1].left) then
        self.speedX = -10
    elseif love.keyboard.isDown(CONTROLS[1].right) then
        self.speedX = 10
    end
    
    self.speedX = self.speedX - self.speedX*dt*4
end

function Mario:draw()
    self.world:drawObject(self)
end

function Mario:jump()
    self.onGround = false
    self.speedY = -JUMPFORCE
end