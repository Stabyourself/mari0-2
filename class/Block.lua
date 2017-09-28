Block = class("Block", PhysObj)

function Block:initialize(world, x, y)
    self.block = true
    self.blockX = x
    self.blockY = y
    
    PhysObj.initialize(self, world, x-1, y-1)

    self.static = true
end