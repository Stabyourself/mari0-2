local FrameTimeAnalyser = class("FrameTimeAnalyser")

function FrameTimeAnalyser:initialize(amount)
    self.amount = amount or 320
    
    self.data = {}
end

function FrameTimeAnalyser:frameStart()
    self.startTime = love.timer.getTime()
end

function FrameTimeAnalyser:frameEnd()
    local currentTime = love.timer.getTime()
    local diff = currentTime - self.startTime
    
    table.insert(self.data, diff)
    
    if #self.data > self.amount then
        table.remove(self.data, 1)
    end
end

function FrameTimeAnalyser:render(x, y, w, h)
    local min = math.huge
    local max = 0
    
    for _, v in ipairs(self.data) do
        if v > max then
            max = v
        end
        
        if v < min then
            min = v
        end
    end
    
    for x = x+w-1, 0, -1 do
        local setI = x
        local t = self.data[setI]
        if t then
            local barHeight = (t - min) / (max - min)
            
            
            if t then
                love.graphics.rectangle("fill", x*SCALE, (h-h*barHeight)*SCALE, SCALE, h*barHeight*SCALE)
            end
        end
    end
    
    love.graphics.setColor(255, 0, 0)
    marioPrint(math.round(max*1000, 2), 0, 0) -- max
    marioPrint(math.round(min*1000, 2), 0, h-7) -- min
    love.graphics.setColor(255, 255, 255)
end

return FrameTimeAnalyser