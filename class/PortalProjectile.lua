local PortalProjectileNode = require("class.PortalProjectileNode")
local PortalProjectile = class("PortalProjectile")

local projectileImg = love.graphics.newImage("img/portal-projectile.png")

PortalProjectile.speed = 3000--math.huge
PortalProjectile.nodeEvery = 10 -- every X pixels, one node
PortalProjectile.nodeSineOffset = 0.5
PortalProjectile.helixes = 2
PortalProjectile.helixWidth = 3

function PortalProjectile:initialize(level, startX, startY, endX, endY, color)
    self.level = level
    self.startX = startX
    self.startY = startY
    self.endX = endX
    self.endY = endY
    self.color = color

    self.diffX = self.endX - self.startX
    self.diffY = self.endY - self.startY

    self.t = 0
    self.progress = 0

    self.x = 0
    self.y = 0

    self.angle = math.atan2(self.diffY, self.diffX)
    self.nodeAngle = self.angle+math.pi*0.5
    self.nodeDiffX = math.cos(self.angle)*self.nodeEvery
    self.nodeDiffY = math.sin(self.angle)*self.nodeEvery

    -- calculate flight time using very advanced math. the pythagoras theorem.
    self.distance = math.sqrt(self.diffX*self.diffX + self.diffY*self.diffY)
    self.flightTime = self.distance / self.speed

    self.nodes = {}
    self.latestNode = -1

    self.lastNodes = {}
    self.helixNodes = {}
    for h = 1, self.helixes do
        self.helixNodes[h] = {}
        self.lastNodes[h] = PortalProjectileNode:new(self.x, self.y, self.color)
    end
end

function PortalProjectile:getPointOffset(i, h)
    local nodeR = (math.pi*2*(h/self.helixes) + self.nodeSineOffset*i)

    local dist = math.sin(nodeR)*self.helixWidth
    local x = math.cos(self.nodeAngle)*dist
    local y = math.sin(self.nodeAngle)*dist

    return x, y
end

function PortalProjectile:makeNode(i)
    -- calculate x, y
    local baseX = self.startX + i*self.nodeDiffX
    local baseY = self.startY + i*self.nodeDiffY

    -- mek ned
    for h = 1, self.helixes do
        local xAdd, yAdd = self:getPointOffset(i, h)

        local x = baseX + xAdd
        local y = baseY + yAdd

        local node = PortalProjectileNode:new(x, y, self.color, self.helixNodes[h], i, self.lastNodes[h])

        table.insert(self.nodes, node)
        table.insert(self.helixNodes[h], node)
    end
end

function PortalProjectile:update(dt)
    self.t = self.t + dt
    if self.progress < 1 then
        self.progress = math.min(1, Easing.linear(self.t, 0, 1, self.flightTime))

        local oldX = self.x
        local oldY = self.y

        self.x = self.startX + self.diffX * self.progress
        self.y = self.startY + self.diffY * self.progress

        -- create any sidehoes
        -- get the last node that should be there
        local currentI = math.min(1, self.progress)*self.distance / self.nodeEvery
        local newLatestNode = math.floor(currentI)

        for i = self.latestNode+1, newLatestNode do
            self:makeNode(i)
        end

        self.latestNode = newLatestNode

        -- Update lastNode
        for h = 1, self.helixes do
            local xAdd, yAdd = self:getPointOffset(currentI, h)

            self.lastNodes[h].x = self.x + xAdd
            self.lastNodes[h].y = self.y + yAdd
        end
    end

    -- Update the existing nodes
    updateGroup(self.nodes, dt)

    return self.t > self.flightTime + 1
end

local coordinates = {}

function PortalProjectile:draw()
    if self.progress < 1 then -- as long as the projectile is moving, draw it
        love.graphics.setColor(self.color:rgb())
        love.graphics.draw(projectileImg, self.x, self.y, 0, 1, 1, 4, 4)
    end

    -- connect the dots!
    for _, node in ipairs(self.nodes) do
        if self.level:objVisible(node.x, node.y, 0, 0) then
            node:draw()
        end
    end
end

return PortalProjectile
