PortalWall = class("PortalWall", PhysObj)

function PortalWall:initialize(World, x, y)
    self.static = true

    PhysObj.initialize(self, World, x, y)

    self.width = 0
    self.height = 0
end