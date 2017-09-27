PhysObj = class("PhysObj")

function PhysObj:initialize(world, x, y)
    self.x = x
    self.y = y
    self.world = world

    self.speedX = 0
    self.speedY = 0
    self.width = 1
    self.height = 1
    self.onGround = false
    self.static = false
    self.active = true

    self.world:addObject(self)
end

function PhysObj:passiveCollide(otherObj)

end

function PhysObj:floorCollide(otherObj)

end

function PhysObj:ceilCollide(otherObj)

end

function PhysObj:leftCollide(otherObj)

end

function PhysObj:rightCollide(otherObj)

end

function PhysObj:startFall()

end