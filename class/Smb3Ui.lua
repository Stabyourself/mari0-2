Smb3Ui = class("Smb3Ui")

function Smb3Ui:initialize()
    self.pMeter = 0
    
    self.pMeterBlinkTimer = 0
    
    self.skyColor = game.level.backgroundColor
    self.time = 0
    self.world = 1
    self.score = 0
    self.coins = 0
    self.lives = 0
    
    self.canvas = Gui3.Canvas:new(0, SCREENHEIGHT-VAR("uiHeight"), SCREENWIDTH, VAR("uiHeight"))
    self.canvas.gui = defaultUI
    self.canvas.background = {0, 0, 0}
    
    self.uiBox = Gui3.Box:new(16, 3, 150, 26)
    self.uiBox.background = self.skyColor
    self.canvas:addChild(self.uiBox)
    
    self.cardBoxes = {}
    for i = 1, 3 do
        self.cardBoxes[i] = Gui3.Box:new(150+i*28, 3, 22, 26)
        self.cardBoxes[i].background = self.skyColor
        self.canvas:addChild(self.cardBoxes[i])
    end
    
    self.element = {}
    self.element.world = Gui3.Text:new("", 1, 2)
    self.element.pMeter = Gui3.Text:new("", 49, 2)
    self.element.coins = Gui3.Text:new("", 121, 2)
    self.element.lives = Gui3.Text:new("", 1, 10)
    self.element.score = Gui3.Text:new("", 49, 10)
    self.element.time = Gui3.Text:new("", 113, 10)
    
    self.uiBox:addChild(self.element.world)
    self.uiBox:addChild(self.element.pMeter)
    self.uiBox:addChild(self.element.coins)
    self.uiBox:addChild(self.element.lives)
    self.uiBox:addChild(self.element.score)
    self.uiBox:addChild(self.element.time)
    
    self:resize()
end

function Smb3Ui:resize()
    self.canvas:resize(SCREENWIDTH, self.canvas.h)
    self.canvas.y = SCREENHEIGHT-VAR("uiHeight")
    
    self.uiBox.x = (SCREENWIDTH-256)/2+13
    for i, cardBox in ipairs(self.cardBoxes) do
        cardBox.x = (SCREENWIDTH-256)/2+i*24+149
    end
end

function Smb3Ui:update(dt)
    if self.pMeter == VAR("pMeterTicks") then
        self.pMeterBlinkTimer = self.pMeterBlinkTimer + dt
        
        while self.pMeterBlinkTimer > VAR("pMeterBlinkTime")*2 do
            self.pMeterBlinkTimer = self.pMeterBlinkTimer - VAR("pMeterBlinkTime")*2
        end
    end
    
    prof.push("concats")
    self.element.world:setString(self:getWorldText())
    self.element.pMeter:setString(self:getPMeterText())
    self.element.coins:setString(self:getCoinsText())
    self.element.lives:setString(self:getLivesText())
    self.element.score:setString(self:getScoreText())
    self.element.time:setString(self:getTimeText())
    prof.pop()
    
    prof.push("canvas")
    self.canvas:update(dt)
    prof.pop()
end

function Smb3Ui:draw()
    self.canvas:draw()
end

function Smb3Ui:getWorldText()
    return "1234" .. self.world
end

function Smb3Ui:getPMeterText()
    local s = ""
    
    for i = 1, math.min(VAR("pMeterTicks")-1, self.pMeter) do
        s = s .. "A"
    end
    
    for i = 1, VAR("pMeterTicks")-1-self.pMeter do
        s = s .. "B"
    end
    
    if self.pMeter == VAR("pMeterTicks") and self.pMeterBlinkTimer >= VAR("pMeterBlinkTime") then
        s = s .. "CD"
    else
        s = s .. "EF"
    end
    
    return s
end

function Smb3Ui:getCoinsText()
    local s = "$"
    
    if self.coins < 10 then
        s = s .. " " .. self.coins
    else
        s = s .. self.coins
    end
    
    return s
end

function Smb3Ui:getLivesText()
    local s = ""
    s = "MNX"
    
    if self.lives < 10 then
        s = s .. " " .. self.lives
    else
        s = s .. self.lives
    end
    
    return s
end

function Smb3Ui:getScoreText()
    return padZeroes(self.score, 7), x, y
end

function Smb3Ui:getTimeText()
    return "T" .. padZeroes(self.time, 3)
end
