function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    scale = 4
    colors = {}
    files = love.filesystem.getDirectoryItems("")
    
    for i = #files, 1, -1 do
        if string.sub(files[i], -4) ~= ".png" or string.find(files[i], "collisions") then
            table.remove(files, i)
        else
            files[i] = string.sub(files[i], 1, -5)
        end
    end
    
    currentFile = 1
    
    loadImg()
end

function loadImg()
    colors = {}
    img = love.graphics.newImage(files[currentFile] .. ".png")
    imgData = love.image.newImageData(files[currentFile] .. ".png")
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(files[currentFile] .. " - Arrows to change image, mouse to select colors, R to reset, enter to process current image")
    
    love.graphics.rectangle("fill", 0, 20, #colors*20, 20)
    for i, color in ipairs(colors) do
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", (i-1)*20+1, 21, 18, 18)
    end
    
    love.graphics.setColor(1, 1, 1)
    
    love.graphics.draw(img, 0, 40, 0, scale, scale)
    
    local x, y = love.mouse.getPosition()
    local r, g, b, a = mouseColor(x, y)
    if r then
        love.graphics.rectangle("fill", x, y, 30, 30)
        love.graphics.setColor(r, g, b)
        love.graphics.rectangle("fill", x+1, y+1, 28, 28)
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    
    if key == "right" or key == "down" then
        currentFile = currentFile + 1
        if currentFile > #files then
            currentFile = 1
        end
        loadImg()
    end
    
    if key == "left" or key == "up" then
        currentFile = currentFile - 1
        if currentFile == 0 then
            currentFile = #files
        end
        loadImg()
    end
    
    if key == "r" then
        colors = {}
    end
    
    if key == "return" then
        processImage(files[currentFile], imgData, colors)
    end
end

function mouseColor(x, y)
    x, y = mouseToImage(x, y)
    
    if x >= 0 and x < imgData:getWidth() and y >= 0 and y < imgData:getHeight() then
        return imgData:getPixel(x, y)
    end
    
    return false
end

function mouseToImage(x, y)
    return math.floor(x/scale), math.floor((y-40)/scale)
end

function love.mousepressed(x, y, button)
    local r, g, b, a = mouseColor(x, y)
    
    if r then
        local found = false
        for _, color in ipairs(colors) do
            if color[1] == r and color[2] == g and color[3] == b then
                found = true
                break
            end
        end
        
        if not found then
            table.insert(colors, {r, g, b})
        end
    end
end

function processImage(name, imgData, colors)
    local fileInfo = love.filesystem.getInfo("graphics")
    
    if fileInfo and fileInfo.type == "directory" then
        love.filesystem.createDirectory("graphics")
    end
    
    for i, color in ipairs(colors) do
        local filename = "graphics/" .. name .. "-" .. i .. ".png"
        separateColor(imgData, color):encode("png", filename)
    end
    
    local filename = "graphics/" .. name .. "-static.png"
    separateNotColors(imgData, colors):encode("png", filename)
end

function separateColor(imgData, color)
    local out = love.image.newImageData(imgData:getDimensions())
    
    for y = 0, imgData:getHeight()-1 do
        for x = 0, imgData:getWidth()-1 do
            local r, g, b, a = imgData:getPixel(x, y)
            
            if r == color[1] and g == color[2] and b == color[3] then
                out:setPixel(x, y, 1, 1, 1, a)
            end
        end
    end
    
    return out
end

function separateNotColors(imgData, colors)
    local out = love.image.newImageData(imgData:getDimensions())
    
    for y = 0, imgData:getHeight()-1 do
        for x = 0, imgData:getWidth()-1 do
            local r, g, b, a = imgData:getPixel(x, y)
            
            local found = false
            for _, color in ipairs(colors) do
                if color[1] == r and color[2] == g and color[3] == b then
                    found = true
                end
            end
            
            if not found then
                out:setPixel(x, y, r, g, b, a)
            end
        end
    end
    
    return out
end