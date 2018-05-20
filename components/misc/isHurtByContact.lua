local isHurtByContact = class("misc.isHurtByContact")

function isHurtByContact:initialize(actor, args)
    self.actor = actor
end

function isHurtByContact:rightCollision(dt, actorEvent, obj2)
    self:resolve("left", obj2)
end


function isHurtByContact:leftCollision(dt, actorEvent, obj2)
    self:resolve("right", obj2)
end

function isHurtByContact:resolve(dir, obj2)
    local hurtsByContactComponent = obj2:hasComponent("misc.hurtsByContact")
    if hurtsByContactComponent and hurtsByContactComponent[dir] then
        if not hurtsByContactComponent.onlyWhenMoving or obj2.cache.speed[1] ~= 0 then
            print("This fucking 'kicks' component runs before this so I'm not even aware that the shell wasn't moving woooh")
        end
    end
end

return isHurtByContact