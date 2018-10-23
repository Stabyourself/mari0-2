local Smb3Ui = require "class.Smb3Ui"
local Mari02UI = require "class.Mari02UI"
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

    ui = Smb3Ui:new()
    updateSizes()
end

function Game:update(dt)
    self.level:update(dt)

    prof.push("UI")
    if self.uiVisible then
        if VAR("debug").showFPSInTime then
            ui.time = love.timer.getFPS()
        else
            ui.time = math.ceil(self.level.timeLeft)
        end

        ui:setPMeter(1, self.players[1].actor.pMeter or 0)
        ui:setLives(1, self.players[1].lives)
        ui.score = self.players[1].score
        ui.coins = self.players[1].coins
        ui.world = 1
        ui:update(dt)
    end
    prof.pop("UI")
end

function Game:draw()
    self.level:draw()

    love.graphics.setColor(1, 1, 1)

    prof.push("UI")
    if self.uiVisible then
        ui:draw()
    end
    prof.pop("UI")

    if VAR("debug").animatedTileCallbacks then
        for i, layer in ipairs(self.level.layers) do
            local s = string.format("layer %d: %d", i, #layer.callbacks)
            love.graphics.print(s, 20, 12+i*8)
        end
    end
end

function Game:resize(w, h)
    ui:resize(w, h)
    self.level:resize(w, h)
end

function Game:cmdpressed(key)
    self.level:cmdpressed(key)
end

function Game:mousepressed(x, y, button)
    self.level:mousepressed(x, y, button)
end

return Game
