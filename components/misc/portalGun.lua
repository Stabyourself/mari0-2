local component = {}

function component.setup(actor)
    actor.portals = {}
    actor.hasPortalGun = true--true
    
    actor.portalGunAngle = 0
    
    actor.portalColor = {
        Color.fromHSV(200/360, 0.76, 0.99),
        Color.fromHSV(30/360, 0.87, 0.91),
        Color.fromHSV(30/360, 0.87, 0.91),
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

return component