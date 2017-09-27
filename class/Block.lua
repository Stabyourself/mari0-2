Block = class("Block", PhysObj)

function Block:initialize(world, x, y)
    PhysObj.initialize(self, world, x, y)

    self.static = true
end