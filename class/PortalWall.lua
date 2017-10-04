PortalWall = class("PortalWall", PhysObj)

function PortalWall:initialize(world, x, y)
    self.static = true

    PhysObj.initialize(self, world, x, y)

    self.width = 0
    self.height = 0
end