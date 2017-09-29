function loadEnemies()
    local enemyList = {}

    local files = love.filesystem.getDirectoryItems("enemies")

    for _, file in ipairs(files) do
        local name = file:match("(.+)%..+")
        local extension = file:match("^.+(%..+)$")

        if extension == ".json" then
            local json = loadEnemy("enemies/" .. file)
            local img = love.graphics.newImage("enemies/" .. name .. ".png")
            local quad = {}

            -- Generate quads
            if json.animation == "frames" then
                for i = 1, json.frames do
                    local width = img:getWidth()/json.frames
                    
                    quad[i] = love.graphics.newQuad((i-1)*width, 0, width, img:getHeight(), img:getWidth(), img:getHeight())
                end
            end

            enemyList[name] = {}
            enemyList[name].json = json
            enemyList[name].img = img
            enemyList[name].quad = quad
        end
    end

    return enemyList
end

function loadEnemy(file)
    local json = JSON:decode(love.filesystem.read(file))

    return json
end