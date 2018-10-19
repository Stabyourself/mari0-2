local Smb3Ui = class("Smb3Ui")


local uiHeight = 38
local uiLineHeight = 1

Smb3Ui.height = uiHeight + 1

local pMeterQuad = {
    love.graphics.newQuad(0, 0, 16, 8, 32, 8),
    love.graphics.newQuad(16, 0, 16, 8, 32, 8),
}

local lifeQuad = love.graphics.newQuad(0, 0, 16, 8, 16, 72)

function Smb3Ui:initialize()
    self.pMeter = 0

    self.pMeterBlinkTimer = 0

    self.skyColor = game.level.backgroundColor
    self.time = 0
    self.world = 1
    self.score = 0
    self.coins = 0
    self.lives = 0

    self.canvas = Gui3.Canvas:new(0, SCREENHEIGHT-uiHeight, SCREENWIDTH, uiHeight)
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

    self.element.worldImg = Gui3.Image:new("img/ui/world.png", 1, 2)
    self.element.world = Gui3.Text:new("", 33, 2)

    self.element.pMeter = Gui3.Text:new("", 49, 2)
    self.element.pMeterImg = Gui3.Image:new("img/ui/p_is_for_power.png", 97, 2, pMeterQuad[1])

    self.element.coins = Gui3.Text:new("", 121, 2)

    self.element.livesImg = Gui3.Image:new("img/ui/mario.png", 1, 10, lifeQuad)
    self.element.lives = Gui3.Text:new("", 17, 10)

    self.element.score = Gui3.Text:new("", 49, 10)

    self.element.time = Gui3.Text:new("", 112, 10)


    self.uiBox:addChild(self.element.worldImg)
    self.uiBox:addChild(self.element.world)

    self.uiBox:addChild(self.element.pMeter)
    self.uiBox:addChild(self.element.pMeterImg)

    self.uiBox:addChild(self.element.coins)

    self.uiBox:addChild(self.element.livesImg)
    self.uiBox:addChild(self.element.lives)

    self.uiBox:addChild(self.element.score)

    self.uiBox:addChild(self.element.time)


    self:resize()
end

function Smb3Ui:resize()
    self.canvas:resize(SCREENWIDTH, self.canvas.h)
    self.canvas.y = SCREENHEIGHT-uiHeight

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
    self.element.pMeterImg:setQuad(pMeterQuad[self:getPMeterStatus()])
    self.element.coins:setString(self:getCoinsText())
    self.element.lives:setString(self:getLivesText())
    self.element.score:setString(self:getScoreText())
    self.element.time:setString(self:getTimeText())
    prof.pop()
end

function Smb3Ui:draw()
    love.graphics.push()
    love.graphics.origin()
    self.canvas:rootDraw()
    love.graphics.pop()
end

function Smb3Ui:getWorldText()
    return string.format("%s", self.world)
end

function Smb3Ui:getPMeterText()
    return string.format("%s%s",
        string.rep("⇒", math.min(VAR("pMeterTicks")-1, self.pMeter)), -- "on" ticks
        string.rep("→", VAR("pMeterTicks")-1-self.pMeter) -- "off" ticks
)
end

function Smb3Ui:getPMeterStatus()
    return (self.pMeter == VAR("pMeterTicks") and self.pMeterBlinkTimer >= VAR("pMeterBlinkTime")) and 2 or 1
end

function Smb3Ui:getCoinsText()
    return string.format("$%2d", self.coins)
end

function Smb3Ui:getLivesText()
    return string.format("×%2d", self.lives)
end

function Smb3Ui:getScoreText()
    return string.format("%07d", self.score)
end

function Smb3Ui:getTimeText()
    return string.format("◔%03d", self.time)
end

function Smb3Ui:setPMeter(i, val)
    self.pMeter = val
end

function Smb3Ui:setLives(i, val)
    self.lives = val
end

return Smb3Ui
