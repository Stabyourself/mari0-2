-- Frame time analyser thing, written for Mari0 3DS - MIT License.
local FTAnalyser = class("FTAnalyser")

function FTAnalyser:initialize(amount)
    self.amount = amount or 320
    
    self.data = {}
    self.minSmooth = false
    self.maxSmooth = false
end

function FTAnalyser:frameStart()
    self.startTime = love.timer.getTime()
    self.frameColor = false
end

function FTAnalyser:frameMark(r, g, b)
    self.frameColor = {r, g, b}
end

function FTAnalyser:frameEnd(dt)
    local currentTime = love.timer.getTime()
    local t = currentTime - self.startTime
    
    local frame = {
        t = t
    }

    if self.frameColor then
        frame.color = self.frameColor
    end

    table.insert(self.data, frame)

    
    if #self.data > self.amount then
        table.remove(self.data, 1)
    end
    self.min = math.huge
    self.max = 0
    
    for _, v in ipairs(self.data) do
        if v.t > self.max then
            self.max = v.t
        end
        
        if v.t < self.min then
            self.min = v.t
        end
    end

    if not self.minSmooth then
        self.minSmooth = self.min
        self.maxSmooth = self.max
    else
        if self.min > self.minSmooth then
            self.minSmooth = math.min(self.min, self.minSmooth + 0.02*dt)
        elseif self.min < self.minSmooth then
            self.minSmooth = math.max(self.min, self.minSmooth - 0.02*dt)
        end

        if self.max > self.maxSmooth then
            self.maxSmooth = math.min(self.max, self.maxSmooth + 0.02*dt)
        elseif self.max < self.maxSmooth then
            self.maxSmooth = math.max(self.max, self.maxSmooth - 0.02*dt)
        end
    end
end

function FTAnalyser:draw(x, y, w, h)
    local graphHeight = h-16
    local graphOffset = 8

    local minMaxDiff = self.maxSmooth - self.minSmooth

    local total = 0

    for _, v in ipairs(self.data) do
        total = total + v.t
    end

    local avg = total/#self.data

    for x = x+w, 1, -1 do
        local setI = x
        if self.data[setI] then
            local t = self.data[setI].t
            local barHeight = (t - self.minSmooth) / minMaxDiff
            
            
            if t then
                if self.data[setI].color then
                    love.graphics.setColor(self.data[setI].color)
                end
                love.graphics.rectangle("fill", x+(self.amount-#self.data)-1, (h-graphOffset-graphHeight*barHeight)+y, 1, (h-graphOffset*2)*barHeight)
            end
        end

        love.graphics.setColor(255, 255, 255)
    end
    
    love.graphics.setColor(255, 0, 0)
    love.graphics.print("max ms: " .. math.round(self.max*1000, 2), x, y)
    love.graphics.print("min ms: " .. math.round(self.min*1000, 2), x, h-7+y)
    love.graphics.print("avg ms: " .. math.round(avg*1000, 2), x+w-1, y, "right")
    love.graphics.setColor(255, 255, 255)
end

return FTAnalyser