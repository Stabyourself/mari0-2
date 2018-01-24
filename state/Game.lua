Game = class("Game")

function Game:load()
    gameState = "game"

    self.timeLeft = 400
    
    SmbMario = require("characters.smb-mario.code")
    Smb3Mario = require("characters.smb3-mario.code")
    
    self.level = Level:new("levels/smb3test.json")
    
    smb3ui = Smb3Ui:new()
    self.uiVisible = true
    
    love.graphics.setBackgroundColor(self.level.backgroundColor)
end

function Game:update(dt)
    self.timeLeft = math.max(0, self.timeLeft-2.5*dt)
    
    self.level:update(dt)
    
    if self.level.marios[1].y > self.level.height*self.level.tileSize+.5 then
        self.level.marios[1].y = -1
    end
    
    if self.uiVisible then
        smb3ui:update(dt)
    end
end

function Game:draw()
    self.level:draw()

    love.graphics.setColor(1, 1, 1)
    
    if self.uiVisible then
        smb3ui.time = math.floor(love.timer.getFPS())--math.ceil(self.timeLeft)
        smb3ui.pMeter = self.level.marios[1].pMeter
        smb3ui.score = 160291
        smb3ui.lives = 4
        smb3ui.coins = 23
        smb3ui.world = 1
        smb3ui:draw()
    end
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