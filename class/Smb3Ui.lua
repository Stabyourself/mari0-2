Smb3Ui = class("Smb3Ui")

local pMeterTick = love.graphics.newImage("img/pMeterTick.png")

function Smb3Ui:initialize()
    self.pMeter = 0
    
    self.time = 0
    self.world = 1
    self.score = 0
    self.coins = 0
    self.lives = 0
end

function Smb3Ui:draw()
    love.graphics.push()
    
    love.graphics.setColor(0, 0, 0)
    love.graphics.translate(0, SCREENHEIGHT-UIHEIGHT)
    love.graphics.rectangle("fill", 0, 0, SCREENWIDTH, UIHEIGHT)
    love.graphics.translate((SCREENWIDTH-256)/2, 0)
    
    love.graphics.setColor(255, 255, 255)
    -- Bawxes
    defaultUI:box(16, 6, 146, 20)
    defaultUI:box(176, 6, 18, 20)
    defaultUI:box(200, 6, 18, 20)
    defaultUI:box(224, 6, 18, 20)
    
    --P Meter
    local UIstring1 = "&World1;&World2;&World3;&World4;" ..  self.world .. " "
    
    for i = 1, math.min(PMETERTICKS-1, self.pMeter) do
        UIstring1 = UIstring1 .. "&pMeterTickOn;"
    end
    
    for i = 1, PMETERTICKS-1-self.pMeter do
        UIstring1 = UIstring1 .. "&pMeterTick;"
    end
    
    if self.pMeter == 7 then
        UIstring1 = UIstring1 .. "&pMeterOn1;&pMeterOn2;"
    else
        UIstring1 = UIstring1 .. "&pMeter1;&pMeter2;"
    end
    
    UIstring1 = UIstring1 .. " &Dollarinos;"
    
    if self.coins < 10 then
        UIstring1 = UIstring1 .. " " .. self.coins
    else
        UIstring1 = UIstring1 .. self.coins
    end
    
    marioPrint(UIstring1, 17, 8)
    
    UIstring2 = "&Mario1;&Mario2;&Times;"
    
    if self.lives < 10 then
        UIstring2 = UIstring2 .. " " .. self.lives
    else
        UIstring2 = UIstring2 .. self.lives
    end
    UIstring2 = UIstring2 .. " " .. padZeroes(self.score, 7) .. " &Time;" .. padZeroes(self.time, 3)
    marioPrint(UIstring2, 17, 16)
    
    love.graphics.pop()
end