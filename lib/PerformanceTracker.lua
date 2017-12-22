-- Performance tracker thing, written for Mari3 - MIT License.
local PerformanceTracker = class("PerformanceTracker")

function PerformanceTracker:initialize()
    self.data = {}
    self:reset()
end

function PerformanceTracker:reset()
    for i, _ in pairs(self.data) do
        self.data[i] = 0
    end
end

function PerformanceTracker:track(type, num)
    if not self.data[type] then
        self.data[type] = 0
    end

    self.data[type] = self.data[type] + (num or 1)
end

function PerformanceTracker:draw(x, y)
    local row = 1

    for i, v in pairs(self.data) do
        love.graphics.print(i .. ": " .. v, x, y+(row-1)*8)
        row = row + 1
    end
end

return PerformanceTracker