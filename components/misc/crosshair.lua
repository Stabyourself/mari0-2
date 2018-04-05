local component = {}

function component.setup(actor)
    actor.crosshair = DottedCrosshair:new(actor)
end

function component.postUpdate(actor, dt)
    local x, y = actor.x+actor.width/2, actor.y+actor.height/2+2
    actor.crosshair.origin.x = x
    actor.crosshair.origin.y = y
    
    local mx, my = actor.world:mouseToWorld()
    
    actor.crosshair.angle = math.atan2(my-y, mx-x)
    
    actor.portalGunAngle = actor.crosshair.angle
    
    prof.push("Crosshair")
    actor.crosshair:update(dt)
    prof.pop()
end

function component.draw(actor)
    actor.crosshair:draw()
end

return component
