local component = {}

function component.setup(actor)
    actor.portals = {}
    actor.hasPortalGun = true--true
    
    actor.portalGunAngle = 0
    
    actor.portalColor = {
        Color3.fromHSV(200/360, 0.76, 0.99),
        Color3.fromHSV(30/360, 0.87, 0.91),
        Color3.fromHSV(30/360, 0.87, 0.91),
    }
end

function component.closePortals(actor)
    for i = 1, 2 do
        if actor.portals[i] then
            actor.portals[i].deleteMe = true
            actor.portals[i] = nil
        end
    end
end

function component.click(actor, dt, actorEvent, args, button)
    if button == 1 or button == 2 then
        if actor.crosshair.target.valid then
            local portal = actor.world:attemptPortal(actor.crosshair.target.layer, actor.crosshair.target.tileX, actor.crosshair.target.tileY, actor.crosshair.target.blockSide, actor.crosshair.target.worldX, actor.crosshair.target.worldY, actor.portalColor[button], actor.portals[button])
            
            if portal then
                if actor.portals[button] then
                    actor.portals[button].deleteMe = true
                end
                
                actor.portals[button] = portal
                        
                if actor.portals[1] and actor.portals[2] then
                    actor.portals[1]:connectTo(actor.portals[2])
                    actor.portals[2]:connectTo(actor.portals[1])

                    actor.portals[button].timer = actor.portals[button].connectsTo.timer
                end
            end
        end
    end
end

return component