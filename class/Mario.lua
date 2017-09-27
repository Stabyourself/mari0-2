Mario = class("Mario", PhysObj)

function Mario:initialize(world, x, y)
    PhysObj.initialize(self, world, x, y)

    self.width = 12/TILESIZE
    self.height = 12/TILESIZE
end