actorTemplates = {}

local dir = "actorTemplates/"

local files = love.filesystem.getDirectoryItems(dir)

for _, file in ipairs(files) do
    if string.sub(file, -4) == "json" then
        local name = string.sub(file, 1, -6)
        local template = JSON:decode(love.filesystem.read(dir .. file))

        local componentsLinked = {}
        -- Link the components to our components table
        for i, v in pairs(template.components) do
            table.insert(componentsLinked, {component = components[i], args = v})
        end
        template.components = componentsLinked

        -- Load images
        if template.img then
            if type(template.img) == "table" then
                local imgLoaded = {}

                for i, v in pairs(template.img) do
                    local loadAs = i

                    if tonumber(loadAs) then
                        loadAs = tonumber(loadAs)
                    end

                    imgLoaded[loadAs] = love.graphics.newImage(v)
                end

                template.img = imgLoaded
            else   
                template.img = love.graphics.newImage(template.img) -- todo: replace with some smart-ass directory thing
            end
        end

        actorTemplates[name] = template
    end
end