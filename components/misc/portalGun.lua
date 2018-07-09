local PortalProjectile = require "class.PortalProjectile"
local Component = require "class.Component"
local portalGun = class("misc.portalGun", Component)

portalGun.defaultColors = {
    Color3.fromHSV(200/360, 0.76, 0.99),
    Color3.fromHSV(30/360, 0.87, 0.91),
}

function portalGun:initialize(actor, args)
    Component.initialize(self, actor, args)

    self.actor.hasPortalGun = true
    self.actor.portalGunAngle = 0

    self.portals = {}
end

function portalGun:closePortals()
    for i = 1, 2 do
        if self.portals[i] then
            self.portals[i].deleteMe = true
            self.portals[i] = nil
        end
    end
end

function portalGun:click(dt, actorEvent, button)
    if button == 1 or button == 2 then
        local hasCrosshair = self.actor:hasComponent("misc.crosshair")

        assert(hasCrosshair, "Actor tried to fire a portal without having a crosshair.")

        local crosshair = hasCrosshair.crosshair

        if crosshair.target.valid then
            local color = self.actor.player and self.actor.player.portalColors and self.actor.player.portalColors[button] or self.defaultColors[button]

            local portal = self.actor.world:attemptPortal(
                crosshair.target.layer,
                crosshair.target.tileX,
                crosshair.target.tileY,
                crosshair.target.blockSide,
                crosshair.target.worldX,
                crosshair.target.worldY,
                color,
                self.portals[button])

            if portal then
                if self.portals[button] then
                    self.portals[button].deleteMe = true
                end

                self.portals[button] = portal

                if self.portals[1] and self.portals[2] then
                    self.portals[1]:connectTo(self.portals[2])
                    self.portals[2]:connectTo(self.portals[1])

                    self.portals[button].timer = self.portals[button].connectsTo.timer
                end
            end

            -- Create projectile
            table.insert(self.actor.world.portalProjectiles, PortalProjectile:new(
                self.actor.world,
                crosshair.origin.x,
                crosshair.origin.y,
                crosshair.target.worldX,
                crosshair.target.worldY,
                color
            ))
        end
    end
end

return portalGun