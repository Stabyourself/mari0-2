local transforms = class("misc.transforms", Component)

transforms.argList = {
    {"on", "required|string"},
    {"into", "required|actorTemplate"},
}

function transforms:initialize(actor, args)
    Component.initialize(self, actor, args)

    self[self.on] = function(self)
        self.actor:loadActorTemplate(actorTemplates[self.into])
    end
end

return transforms
