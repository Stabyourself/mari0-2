local Player = class("Player")

function Player:initialize(i, settings)
    self.i = i

    self.coins = 0
    self.score = 0
    self.lives = 3

    if settings.palette then
        self.palette = convertPalette(settings.palette)
    end

    if settings.portalColors then
        self.portalColors = settings.portalColors
    end
end

return Player
