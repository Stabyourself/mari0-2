local portalGun = class("misc.portalGun")

function portalGun:initialize(actor, args)
    self.actor = actor
    self.args = args

    self:setup()
end

function portalGun:setup()
    self.actor.portals = {}
    self.actor.hasPortalGun = true--true
    
    self.actor.portalGunAngle = 0
    
    self.actor.portalColor = {
        Color3.fromHSV(200/360, 0.76, 0.99),
        Color3.fromHSV(30/360, 0.87, 0.91),
        Color3.fromHSV(30/360, 0.87, 0.91),
    }
end

function portalGun:closePortals()
    for i = 1, 2 do
        if self.actor.portals[i] then
            self.actor.portals[i].deleteMe = true
            self.actor.portals[i] = nil
        end
    end
end

function portalGun:click(dt, actorEvent, button)
    if button == 1 or button == 2 then
        if self.actor.crosshair.target.valid then
            local portal = self.actor.world:attemptPortal(self.actor.crosshair.target.layer, self.actor.crosshair.target.tileX, self.actor.crosshair.target.tileY, self.actor.crosshair.target.blockSide, self.actor.crosshair.target.worldX, self.actor.crosshair.target.worldY, self.actor.portalColor[button], self.actor.portals[button])
            
            if portal then
                if self.actor.portals[button] then
                    self.actor.portals[button].deleteMe = true
                end
                
                self.actor.portals[button] = portal
                        
                if self.actor.portals[1] and self.actor.portals[2] then
                    self.actor.portals[1]:connectTo(self.actor.portals[2])
                    self.actor.portals[2]:connectTo(self.actor.portals[1])

                    self.actor.portals[button].timer = self.actor.portals[button].connectsTo.timer
                end
            end
        end
    end
end

return portalGun