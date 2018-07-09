local PortalProjectileNode = require("class.PortalProjectileNode")
local PortalProjectile = class("PortalProjectile")

local projectileImg = love.graphics.newImage("img/portal-projectile.png")

PortalProjectile.speed = 1500
PortalProjectile.nodeEvery = 20 -- every X pixels, one node
PortalProjectile.helixes = 2

function PortalProjectile:initialize(startX, startY, endX, endY, color)
    print(color)
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
    self.nodeDiffX = math.cos(self.angle)*self.nodeEvery
    self.nodeDiffY = math.sin(self.angle)*self.nodeEvery

    -- calculate flight time using very advanced math. the pythagoras theorem.
    self.distance = math.sqrt(self.diffX*self.diffX + self.diffY*self.diffY)
    self.flightTime = self.distance / self.speed

    self.nodes = {}
    self.latestNode = -1
end

function PortalProjectile:update(dt)
    self.t = self.t + dt
    self.progress = math.min(1, Easing.linear(self.t, 0, 1, self.flightTime))

    local oldX = self.x
    local oldY = self.y

    self.x = self.startX + self.diffX * self.progress
    self.y = self.startY + self.diffY * self.progress

    -- create any sidehoes
    -- get the last node that should be there
    local newLatestNode = math.floor(self.progress*self.distance / self.nodeEvery)

    for i = self.latestNode+1, newLatestNode do
        -- calculate x, y
        local x = self.startX + i*self.nodeDiffX
        local y = self.startY + i*self.nodeDiffY

        -- mek ned
        local node = PortalProjectileNode:new(x, y, self.angle, i)
        -- node.parent = self.nodes[] -- maybe
        table.insert(self.nodes, node)
    end

    self.latestNode = newLatestNode

    -- Update the existing nodes
    updateGroup(self.nodes, dt)

    return self.progress >= 1 and #self.nodes == 0
end

local coordinates = {}

function PortalProjectile:draw()
    love.graphics.setColor(self.color:rgb())
    if self.progress < 1 then
        love.graphics.draw(projectileImg, self.x, self.y, 0, 1, 1, 4, 4)
    end

    -- connect the dots!
    if #self.nodes >= 1 then -- need a node to correctly draw a line
        for i = 1, self.helixes do
            iClearTable(coordinates)

            for _, node in ipairs(self.nodes) do
                local x, y = node:getPosition(i, self.helixes)
                table.insert(coordinates, x)
                table.insert(coordinates, y)
            end

            -- insert the current position for good luck
            table.insert(coordinates, self.x)
            table.insert(coordinates, self.y)

            love.graphics.line(coordinates)
        end
    end
end

return PortalProjectile
