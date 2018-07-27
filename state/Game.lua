local Smb3Ui = require "class.Smb3Ui"
local Player = require "class.Player"
local Level = require "class.Level"
local Mappack = require "class.Mappack"

local Game = class("Game")

function Game:initialize(mappack, playerCount)
    -- Create player objects
    self.players = {}
    for i = 1, playerCount do
        table.insert(self.players, Player:new(i, SETTINGS.players[i]))
    end

    -- Load the mappack
    self.mappack = Mappack:new(mappack)
end

function Game:load()
    gameState = "game"

    -- Load the first level
    self.level = self.mappack:startLevel()

    self.uiVisible = true -- should this be part of Game?

    smb3ui = Smb3Ui:new()
end

function Game:update(dt)
    self.level:update(dt)

    prof.push("UI")
    if self.uiVisible then
        smb3ui.time = love.timer.getFPS()--math.ceil(self.level.timeLeft)
        smb3ui.pMeter = self.players[1].actor.pMeter or 0
        smb3ui.score = self.players[1].score
        smb3ui.lives = self.players[1].lives
        smb3ui.coins = self.players[1].coins
        smb3ui.world = 1
        smb3ui:update(dt)
    end
    prof.pop("UI")
end

function Game:draw()
    self.level:draw()

    love.graphics.setColor(1, 1, 1)

    prof.push("UI")
    if self.uiVisible then
        smb3ui:draw()
    end
    prof.pop("UI")
end

function Game:resize(w, h)
    smb3ui:resize(w, h)
    self.level:resize(w, h)
end

function Game:cmdpressed(key)
    self.level:cmdpressed(key)
end

function Game:mousepressed(x, y, button)
    self.level:mousepressed(x, y, button)
end

return Game
