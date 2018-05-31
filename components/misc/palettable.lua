local palettable = class("misc.palettable")

function palettable:initialize(actor, args)
    self.actor = actor
    self.args = args

    self:setup()
end

function palettable:setup(s)
    self.actor.imgPalette = convertPalette(self.args.imgPalette)

    self.actor.defaultPalette = convertPalette(self.args.defaultPalette or self.args.imgPalette)

    self.actor.palette = self.actor.defaultPalette
end

return palettable
