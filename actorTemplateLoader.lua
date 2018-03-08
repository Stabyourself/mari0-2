actorTemplates = {}

local dir = "actorTemplates/"

local files = love.filesystem.getDirectoryItems(dir)

for _, file in ipairs(files) do
    if string.sub(file, -4) == "json" then
        local name = string.sub(file, 1, -6)

        actorTemplates[name] = JSON:decode(love.filesystem.read(dir .. file))

        -- Link the components to our components table
        for i, v in ipairs(actorTemplates[name].components) do
            actorTemplates[name].components[i] = components[v]
        end

        -- Load images
        if actorTemplates[name].img then
            actorTemplates[name].img = love.graphics.newImage("img/" .. actorTemplates[name].img) -- todo: replace with some smart-ass directory thing
        end
    end
end
