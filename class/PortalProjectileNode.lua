local PortalProjectileNode = class("PortalProjectileNode")

PortalProjectileNode.duration = 1
PortalProjectileNode.angleChange = 0.1
PortalProjectileNode.speedChange = 100
PortalProjectileNode.lineMax = 15
PortalProjectileNode.lineMin = 5
PortalProjectileNode.maxAlpha = 1
PortalProjectileNode.connectWith = 2

function PortalProjectileNode.getAlpha(dist)
    if dist > PortalProjectileNode.lineMax then
        return false
    elseif dist < PortalProjectileNode.lineMin then
        return 1
    else
        return math.max(0, math.min(1, 1-dist/PortalProjectileNode.lineMax))
    end
end

function PortalProjectileNode:initialize(x, y, color, nodes, i)
    self.x = x
    self.y = y
    self.color = Color3.fromHSV(color:lighten(love.math.random(0, 80)/100))

    self.r = love.math.random()*math.pi*2
    self.speed = love.math.random(10, 400)/10

    self.nodes = nodes
    self.i = i

    self.t = 0
end

function PortalProjectileNode:update(dt)
    self.t = self.t + dt

    self.r = self.r + (love.math.random()*2-1)*self.angleChange*dt
    self.speed = self.speed + (love.math.random()*2-1)*self.speedChange*dt

    self.x = self.x + math.cos(self.r)*self.speed*dt
    self.y = self.y + math.sin(self.r)*self.speed*dt
end

function PortalProjectileNode:draw()
    local r, g, b = self.color:rgb()
    local fadeA = (1-self.t/self.duration) * self.maxAlpha

    for i = self.i+1, self.i+1+self.connectWith do
        local node = self.nodes[i]

        if node then
            local dist = math.sqrt((self.x-node.x)*(self.x-node.x) + (self.y-node.y)*(self.y-node.y))

            local a = self.getAlpha(dist)

            if a then
                a = a * fadeA

                love.graphics.setColor(r, g, b, a)
                love.graphics.line(self.x, self.y, node.x, node.y)
            end
        end
    end

    -- love.graphics.setColor(r, g, b, fadeA)
    -- love.graphics.rectangle("fill", self.x-.5, self.y-.5, 1, 1)
end

return PortalProjectileNode
