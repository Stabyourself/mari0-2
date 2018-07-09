local PortalProjectileNode = class("PortalProjectileNode")

PortalProjectileNode.duration = 1
PortalProjectileNode.spinSpeed = 5
PortalProjectileNode.helixWidth = 4
PortalProjectileNode.iOffsetMul = 1

function PortalProjectileNode:initialize(x, y, r, i)
    self.x = x
    self.y = y
    self.r = r + math.pi*0.5
    self.iOffset = i*self.iOffsetMul

    self.t = 0
end

function PortalProjectileNode:update(dt)
    self.t = self.t + dt

    return self.t >= self.duration
end

function PortalProjectileNode:getPosition(helixI, helixCount)
    local add = (math.pi*2*(helixI/helixCount))

    local dist = math.sin(self.t*self.spinSpeed + self.iOffset + add)*self.helixWidth

    local x = self.x + math.cos(self.r)*dist
    local y = self.y + math.sin(self.r)*dist

    return x, y
end

return PortalProjectileNode
