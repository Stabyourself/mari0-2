local PortalProjectileNode = require("class.PortalProjectileNode")
local PortalProjectile = class("PortalProjectile")

local projectileImg = love.graphics.newImage("img/portal-projectile.png")

PortalProjectile.speed = 1500
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

    self.helixNodes = {}
    for h = 1, self.helixes do
        self.helixNodes[h] = {}
    end
end

function PortalProjectile:makeNode(i)
    -- calculate x, y
    local baseX = self.startX + i*self.nodeDiffX
    local baseY = self.startY + i*self.nodeDiffY

    -- mek ned
    for h = 1, self.helixes do
        local nodeR = (math.pi*2*(h/self.helixes) + self.nodeSineOffset*i)

        local dist = math.sin(nodeR)*self.helixWidth
        local x = baseX + math.cos(self.nodeAngle)*dist
        local y = baseY + math.sin(self.nodeAngle)*dist

        local node = PortalProjectileNode:new(x, y, self.color, self.helixNodes[h], i)

        table.insert(self.nodes, node)
        table.insert(self.helixNodes[h], node)
    end
end

function PortalProjectile:update(dt)
    self.t = self.t + dt
    if self.progress < 1 then
        self.progress = Easing.linear(self.t, 0, 1, self.flightTime)

        local oldX = self.x
        local oldY = self.y

        self.x = self.startX + self.diffX * self.progress
        self.y = self.startY + self.diffY * self.progress

        -- create any sidehoes
        -- get the last node that should be there
        local newLatestNode = math.floor(self.progress*self.distance / self.nodeEvery)

        for i = self.latestNode+1, newLatestNode do
            self:makeNode(i)
        end

        self.latestNode = newLatestNode

        if self.progress >= 1 then
            -- insert last position into nodes
            self:makeNode(self.distance/self.nodeEvery)
        end
    end

    -- Update the existing nodes
    updateGroup(self.nodes, dt)

    return self.t > self.flightTime + 1
end

local coordinates = {}

function PortalProjectile:draw()
    love.graphics.setColor(self.color:rgb())
    if self.progress < 1 then
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
