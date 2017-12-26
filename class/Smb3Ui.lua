Smb3Ui = class("Smb3Ui")

function Smb3Ui:initialize()
    self.pMeter = 0
    
    self.pMeterBlinkTimer = 0
    
    self.time = 0
    self.world = 1
    self.score = 0
    self.coins = 0
    self.lives = 0
end

function Smb3Ui:update(dt)
    if self.pMeter == VAR("pMeterTicks") then
        self.pMeterBlinkTimer = self.pMeterBlinkTimer + dt
        
        while self.pMeterBlinkTimer > VAR("pMeterBlinkTime")*2 do
            self.pMeterBlinkTimer = self.pMeterBlinkTimer - VAR("pMeterBlinkTime")*2
        end
    end
end

function Smb3Ui:draw()
    love.graphics.push()
    
    love.graphics.translate(0, SCREENHEIGHT-VAR("uiHeight"))
    
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, SCREENWIDTH, VAR("uiHeight"))
    
    love.graphics.translate((SCREENWIDTH-256)/2, 0)
    
    love.graphics.setColor(255, 255, 255)
    -- Bawxes
    defaultUI:box(16, 6, 146, 20)
    defaultUI:box(176, 6, 18, 20)
    defaultUI:box(200, 6, 18, 20)
    defaultUI:box(224, 6, 18, 20)
    
    --P Meter
    self:drawWorld(17, 8)
    self:drawPMeter(65, 8)
    self:drawCoins(137, 8)
    self:drawLives(17, 16)
    self:drawScore(65, 16)
    self:drawTime(129, 16)
    
    love.graphics.pop()
end

function Smb3Ui:drawWorld(x, y)
    marioPrint("&World1;&World2;&World3;&World4;" ..  self.world, x, y)
end

function Smb3Ui:drawPMeter(x, y)
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
    
    marioPrint(s, x, y)
end

function Smb3Ui:drawCoins(x, y)
    local s = ""
    
    s = s .. "&Dollarinos;"
    
    if self.coins < 10 then
        s = s .. " " .. self.coins
    else
        s = s .. self.coins
    end
    
    marioPrint(s, x, y)
end

function Smb3Ui:drawLives(x, y)
    local s = ""
    s = "&Mario1;&Mario2;&Times;"
    
    if self.lives < 10 then
        s = s .. " " .. self.lives
    else
        s = s .. self.lives
    end
    
    marioPrint(s, x, y)
end

function Smb3Ui:drawScore(x, y)
    marioPrint(padZeroes(self.score, 7), x, y)
end

function Smb3Ui:drawTime(x, y)
    marioPrint("&Time;" .. padZeroes(self.time, 3), x, y)
end
