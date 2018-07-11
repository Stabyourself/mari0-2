local PortalProjectileNode = class("PortalProjectileNode")

PortalProjectileNode.duration = 1
PortalProjectileNode.lineMax = 15
PortalProjectileNode.lineMin = 5
PortalProjectileNode.maxAlpha = 1
PortalProjectileNode.connectNumber = 2
PortalProjectileNode.timeAdd = 0.01
PortalProjectileNode.helixWidth = 3

function PortalProjectileNode.getAlpha(dist)
    if dist > PortalProjectileNode.lineMax then
        return false
    elseif dist < PortalProjectileNode.lineMin then
        return 1
    else
        return math.max(0, math.min(1, 1-dist/PortalProjectileNode.lineMax))
    end
end

function PortalProjectileNode:initialize(x, y, r, h, helixR, color, nodes, i, isLastNode)
    self.baseX = x
    self.baseY = y
    self.color = Color3.fromRGB(color:lighten(love.math.random(0, 80)/100))

    self.washR = love.math.random()*math.pi*2
    self.washSpeed = love.math.random(10, 400)/10

    self.r = r
    self.h = h
    self.helixR = helixR

    self.x = 0
    self.y = 0

    if nodes then
        self.nodes = nodes
        self.i = i
        self.isLastNode = isLastNode

        self.moveTimer = 0
        self.moveTime = self.i*self.timeAdd
        self.washTimer = 0

        self.movedX = 0
        self.movedY = 0
    end
end

function PortalProjectileNode:getHelixOffset()
    local dist = math.sin(self.helixR)*self.helixWidth

    local x = math.cos(self.r+math.pi/2)*dist
    local y = math.sin(self.r+math.pi/2)*dist

    return x, y
end

function PortalProjectileNode:update(dt)
    self.x = self.baseX
    self.y = self.baseY

    self.helixR = self.helixR + dt*10

    local helixMul = Easing.outQuad(self.washTimer, 1, -1, self.duration)

    local addX, addY = self:getHelixOffset()

    self.x = self.x + addX*helixMul
    self.y = self.y + addY*helixMul

    self.moveTimer = self.moveTimer + dt

    if self.moveTimer > self.moveTime then
        self.washTimer = self.washTimer + dt

        self.movedX = self.movedX + math.cos(self.washR)*self.washSpeed*dt
        self.movedY = self.movedY + math.sin(self.washR)*self.washSpeed*dt

        self.x = self.x + self.movedX
        self.y = self.y + self.movedY
    end

    return self.washTimer > self.duration
end

function PortalProjectileNode:draw(fakeLastNode)
    if self.washTimer <= self.duration then
        local r, g, b = self.color:rgb()
        local fadeA = (1-self.washTimer/self.duration) * self.maxAlpha

        if not self.isLastNode then
            for i = self.i+1, math.min(#self.nodes, self.i+1+self.connectNumber) do
                self:connectWith(self.nodes[i], r, g, b, fadeA)
            end

            if self.i > #self.nodes-self.connectNumber then
                self:connectWith(fakeLastNode, r, g, b, fadeA)
            end
        end

        love.graphics.setColor(r, g, b, fadeA)
        love.graphics.rectangle("fill", self.x-.5, self.y-.5, 1, 1)
    end
end

function PortalProjectileNode:connectWith(node, r, g, b, a)
    local dist = math.sqrt((self.x-node.x)*(self.x-node.x) + (self.y-node.y)*(self.y-node.y))

    local distA = self.getAlpha(dist)

    if distA then
        a = a * distA

        love.graphics.setColor(r, g, b, a)
        love.graphics.line(self.x, self.y, node.x, node.y)
    end
end

return PortalProjectileNode
