PhysObj = class("PhysObj")

function PhysObj:initialize(world, x, y)
    self.x = x
    self.y = y
    self.world = world

    self.speedX = 0
    self.speedY = 0
    self.width = 1
    self.height = 1
    self.onGround = true
    self.active = true
    self.r = 0

    self.world:addObject(self)
end

function PhysObj:passiveCollide(obj2)
    
end

function PhysObj:floorCollide(obj2)

end

function PhysObj:ceilCollide(obj2)

end

function PhysObj:leftCollide(obj2)

end

function PhysObj:rightCollide(obj2)

end

function PhysObj:startFall()

end