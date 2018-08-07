local Mari02UI = class("Mari02UI")
local PlayerUI = class("PlayerUI")

Mari02UI.height = 0

local pMeterQuad = {
    love.graphics.newQuad(0, 0, 16, 8, 32, 8),
    love.graphics.newQuad(16, 0, 16, 8, 32, 8),
}

function Mari02UI:initialize()
    self.time = 0
    self.world = 1
    self.score = 0
    self.coins = 0

    self.canvas = Gui3.Canvas:new(0, 8, SCREENWIDTH, 28)
    self.canvas.gui = defaultUI

    self.elements = {}

    self.elements.score = Gui3.Text:new("", 18, 0)

    self.elements.coins = Gui3.Text:new("", 140, 0)

    self.elements.worldImg = Gui3.Image:new("img/ui/world.png", 230, 0)
    self.elements.world = Gui3.Text:new("", 262, 0)

    self.elements.time = Gui3.Text:new("", 349, 0)


    self.canvas:addChild(self.elements.worldImg)
    self.canvas:addChild(self.elements.world)

    self.canvas:addChild(self.elements.coins)

    self.canvas:addChild(self.elements.score)

    self.canvas:addChild(self.elements.time)

    self.playerUIs = {}

    local icons = {
        "img/ui/mario.png",
        "img/ui/luigi.png",
        "img/ui/chell.png",
        "img/ui/portaldude.png",
    }

    for i = 1, 4 do
        table.insert(self.playerUIs, PlayerUI:new((i-1)*100+18, 12, icons[i]))
        self.canvas:addChild(self.playerUIs[i].canvas)
    end

    self:resize()
end

function Mari02UI:resize()
    self.canvas:resize(SCREENWIDTH, self.canvas.h)
end

function Mari02UI:update(dt)
    prof.push("concats")
    self.elements.world:setString(self:getWorldText())
    self.elements.coins:setString(self:getCoinsText())
    self.elements.score:setString(self:getScoreText())
    self.elements.time:setString(self:getTimeText())

    for _, playerUI in ipairs(self.playerUIs) do
        playerUI:update(dt)
    end

    prof.pop()
end

function Mari02UI:draw()
    love.graphics.push()
    love.graphics.origin()
    self.canvas:rootDraw()
    love.graphics.pop()
end

function Mari02UI:getWorldText()
    return string.format("%s", self.world)
end

function Mari02UI:getCoinsText()
    return string.format("$%2d", self.coins)
end

function Mari02UI:getScoreText()
    return string.format("%07d", self.score)
end

function Mari02UI:getTimeText()
    return string.format("◔%03d", self.time)
end

function Mari02UI:setPMeter(ply, i)
    self.playerUIs[ply].pMeter = i
end

function Mari02UI:setLives(ply, i)
    self.playerUIs[ply].lives = i
end



function PlayerUI:initialize(x, y, img)
    self.x = x
    self.y = y

    self.lives = 0
    self.pMeter = 0

    self.pMeterBlinkTimer = 0


    self.canvas = Gui3.Canvas:new(self.x, self.y, 64, 16)
    self.canvas.gui = defaultUI

    self.elements = {}

    self.elements.livesImg = Gui3.Image:new(img, 0, 0)
    self.elements.lives = Gui3.Text:new("", 16, 0)

    self.elements.pMeter = Gui3.Text:new("", 0, 8)
    self.elements.pMeterImg = Gui3.Image:new("img/ui/p_is_for_power.png", 48, 8, pMeterQuad[1])


    self.canvas:addChild(self.elements.pMeterImg)
    self.canvas:addChild(self.elements.pMeter)

    self.canvas:addChild(self.elements.livesImg)
    self.canvas:addChild(self.elements.lives)
end

function PlayerUI:update(dt)
    if self.pMeter == VAR("pMeterTicks") then
        self.pMeterBlinkTimer = self.pMeterBlinkTimer + dt

        while self.pMeterBlinkTimer > VAR("pMeterBlinkTime")*2 do
            self.pMeterBlinkTimer = self.pMeterBlinkTimer - VAR("pMeterBlinkTime")*2
        end
    end

    self.elements.pMeter:setString(self:getPMeterText())
    self.elements.pMeterImg:setQuad(pMeterQuad[self:getPMeterStatus()])
    self.elements.lives:setString(self:getLivesText())
end

function PlayerUI:getLivesText()
    return string.format("×%2d", self.lives)
end

function PlayerUI:getPMeterText()
    return string.format("%s%s",
        string.rep("⇒", math.min(VAR("pMeterTicks")-1, self.pMeter)), -- "on" ticks
        string.rep("→", VAR("pMeterTicks")-1-self.pMeter) -- "off" ticks
)
end

function PlayerUI:getPMeterStatus()
    return (self.pMeter == VAR("pMeterTicks") and self.pMeterBlinkTimer >= VAR("pMeterBlinkTime")) and 2 or 1
end

return Mari02UI
