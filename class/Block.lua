Block = class("Block", PhysObj)

function Block:initialize(world, x, y)
    self.blockX = x
    self.blockY = y
    
    self.static = true
    self.block = true
    
    PhysObj.initialize(self, world, x-1, y-1)
end