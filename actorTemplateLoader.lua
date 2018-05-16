actorTemplates = {}

local dir = "actorTemplates/"

local files = love.filesystem.getDirectoryItems(dir)

for _, file in ipairs(files) do
    if string.sub(file, -4) == "json" then
        local name = string.sub(file, 1, -6)
        local template = JSON:decode(love.filesystem.read(dir .. file))

        template.name = name

        -- Load images
        if template.img then
            template.img = love.graphics.newImage(template.img) -- todo: replace with some smart-ass directory thing

            if not template.dontAutoQuad then
                -- create quads
                -- Check if image can be nicely divided into quadWidth/Height sized quads
                template.quads = {}

                for y = 1, template.img:getHeight()/template.quadHeight do
                    for x = 1, template.img:getWidth()/template.quadWidth do
                        table.insert(template.quads, love.graphics.newQuad(
                            (x-1)*template.quadWidth,
                            (y-1)*template.quadHeight,
                            template.quadWidth,
                            template.quadHeight,
                            template.img:getWidth(),
                            template.img:getHeight()
                        ))
                    end
                end
            end
        end

        actorTemplates[name] = template
    end
end
