local Smb3Ui = require "class.Smb3Ui"
local Level = require "class.Level"

local Game = class("Game")

function Game:load()
    gameState = "game"

    self.level = Level:new("levels/smb3-test.lua")

    smb3ui = Smb3Ui:new()
    self.uiVisible = true

    self.timeLeft = 400

    love.graphics.setBackgroundColor(self.level.backgroundColor)
end

function Game:update(dt)
    prof.push("Game")
    self.timeLeft = math.max(0, self.timeLeft-(60/42)*dt)

    self.level:update(dt)

    if self.level.marios[1].y > self.level:getYEnd()*self.level.tileSize+.5 then
        self.level.marios[1].y = -1
    end

    prof.push("UI")
    if self.uiVisible then
        smb3ui:update(dt)
    end
    prof.pop()
    prof.pop()
end

function Game:draw()
    prof.push("Game")
    self.level:draw()

    love.graphics.setColor(1, 1, 1)

    prof.push("UI")
    if self.uiVisible then
        smb3ui.time = math.floor(love.timer.getFPS())--math.ceil(self.timeLeft)
        smb3ui.pMeter = self.level.marios[1].pMeter or 0
        smb3ui.score = 160291
        smb3ui.lives = 10
        smb3ui.coins = 23
        smb3ui.world = 1
        smb3ui:draw()
    end
    prof.pop()
    prof.pop()
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
