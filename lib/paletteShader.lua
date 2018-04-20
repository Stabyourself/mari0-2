local paletteShader = {}

local sh_swap_colors = love.filesystem.read("lib/paletteShader.glsl")

local shader = love.graphics.newShader(sh_swap_colors)

function paletteShader.on(imgPalette, newPalette)
    if imgPalette then
        shader:send("n", #imgPalette)
        shader:sendColor("oldColors", unpack(imgPalette))
        shader:sendColor("newColors", unpack(newPalette))
    end
    
    love.graphics.setShader(shader)
end

function paletteShader.off()
    love.graphics.setShader()
end

return paletteShader