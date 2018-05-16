local unrotate = class("misc.unrotate")

function unrotate:initialize(actor, args)
    self.actor = actor
    self.args = args

    self:setup()
end

function unrotate:setup()

end

function unrotate:update(dt)
    if CHEAT("tumble") then
        self.actor.angle = self.actor.angle + self.actor.speed[1]*dt*0.1
        self.actor:unRotate(0)
    else
        self.actor:unRotate(dt)
    end
end

return unrotate
