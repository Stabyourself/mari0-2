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
    
    self.canvas = GUI.Canvas:new(defaultUI, 0, SCREENHEIGHT-VAR("uiHeight"), SCREENWIDTH, VAR("uiHeight"))
    self.canvas.background = {0, 0, 0}
    
    self.uiBox = GUI.Box:new(16, 3, 150, 26)
    self.uiBox.background = self.skyColor
    self.canvas:addChild(self.uiBox)
    
    self.cardBox = {}
    for i = 1, 3 do
        self.cardBox[i] = GUI.Box:new(150+i*28, 3, 22, 26)
        self.cardBox[i].background = self.skyColor
        self.canvas:addChild(self.cardBox[i])
    end
    
    self.element = {}
    self.element.world = GUI.Text:new("", 1, 2)
    self.element.pMeter = GUI.Text:new("", 49, 2)
    self.element.coins = GUI.Text:new("", 121, 2)
    self.element.lives = GUI.Text:new("", 1, 10)
    self.element.score = GUI.Text:new("", 49, 10)
    self.element.time = GUI.Text:new("", 113, 10)
    
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
    for i, v in ipairs(self.cardBox) do
        v.x = (SCREENWIDTH-256)/2+i*24+149
    end
end

function Smb3Ui:update(dt)
    if self.pMeter == VAR("pMeterTicks") then
        self.pMeterBlinkTimer = self.pMeterBlinkTimer + dt
        
        while self.pMeterBlinkTimer > VAR("pMeterBlinkTime")*2 do
            self.pMeterBlinkTimer = self.pMeterBlinkTimer - VAR("pMeterBlinkTime")*2
        end
    end
    
    self.element.world:setString(self:getWorldText())
    self.element.pMeter:setString(self:getPMeterText())
    self.element.coins:setString(self:getCoinsText())
    self.element.lives:setString(self:getLivesText())
    self.element.score:setString(self:getScoreText())
    self.element.time:setString(self:getTimeText())
    
    self.canvas:update(dt)
end

function Smb3Ui:draw()
    self.canvas:draw()
end

function Smb3Ui:getWorldText()
    return "&World1;&World2;&World3;&World4;" .. self.world
end

function Smb3Ui:getPMeterText()
    local s = ""
    
    for i = 1, math.min(VAR("pMeterTicks")-1, self.pMeter) do
        s = s .. "&pMeterTickOn;"
    end
    
    for i = 1, VAR("pMeterTicks")-1-self.pMeter do
        s = s .. "&pMeterTick;"
    end
    
    if self.pMeter == VAR("pMeterTicks") and self.pMeterBlinkTimer >= VAR("pMeterBlinkTime") then
        s = s .. "&pMeterOn1;&pMeterOn2;"
    else
        s = s .. "&pMeter1;&pMeter2;"
    end
    
    return s
end

function Smb3Ui:getCoinsText()
    local s = ""
    
    s = s .. "&Dollarinos;"
    
    if self.coins < 10 then
        s = s .. " " .. self.coins
    else
        s = s .. self.coins
    end
    
    return s
end

function Smb3Ui:getLivesText()
    local s = ""
    s = "&Mario1;&Mario2;&Times;"
    
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
    return "&Time;" .. padZeroes(self.time, 3)
end
