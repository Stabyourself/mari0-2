components = {}

local dir = "components."

local files = love.filesystem.getDirectoryItems(dir)

for _, file in ipairs(files) do
    if string.sub(file, -3) == "lua" then
        local name = string.sub(file, 1, -5)

        components[name] = require(dir .. name)
    end
end
