local palettable = class("misc.palettable", Component)

palettable.argList = {
    {"imgPalette", "required|palette"},
    {"defaultPalette", "palette", function(self) return self.imgPalette end},
}

function palettable:initialize(actor, args)
    Component.initialize(self, actor, args)

    self.actor.imgPalette = self.imgPalette
    self.actor.defaultPalette = self.defaultPalette

    if self.defaultPalette ~= self.imgPalette then
        self.actor.palette = self.defaultPalette
    end
end

return palettable
