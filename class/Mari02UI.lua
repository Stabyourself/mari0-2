local Mari02UI = class("Mari02UI")
local PlayerUI = class("PlayerUI")

local liveQuads = {}

for i = 1, 9 do
    liveQuads[i] = love.graphics.newQuad(0, (i-1)*8, 16, 8, 16, 72)
end

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

    self.canvas = Gui3.Canvas:new(0, 8, SCREENWIDTH, 20)
    self.canvas.gui = defaultUI

    self.elements = {}

    self.elements.score = Gui3.Text:new("", 18, 0)

    self.elements.coins = Gui3.Text:new("", 142, 0)

    self.elements.worldImg = Gui3.Image:new("img/ui/world.png", 235, 0)
    self.elements.world = Gui3.Text:new("", 267, 0)

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
        table.insert(self.playerUIs, PlayerUI:new((i-1)*108+18, 12, icons[i]))
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


    self.canvas = Gui3.Canvas:new(self.x, self.y, 64, 8)
    self.canvas.gui = defaultUI

    self.elements = {}

    self.elements.livesImg = Gui3.Image:new(img, 0, 0, liveQuads[1])
    self.elements.lives = Gui3.Text:new("", 16, 0)

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

    self.elements.lives:setString(self:getLivesText())
    self.elements.livesImg:setQuad(liveQuads[self:getLiveQuad()])
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

function PlayerUI:getLiveQuad()
    if self.pMeter < VAR("pMeterTicks") then
        return self.pMeter+1
    else
        return self.pMeterBlinkTimer >= VAR("pMeterBlinkTime") and 9 or 8
    end
end

return Mari02UI
