local paletteShader = {}

local sh_swap_colors = [[
    extern number n = 1;
    extern vec4 oldColors[100];
    extern vec4 newColors[100];

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords){
        vec4 pixel = Texel(texture, texture_coords);

        for (int i = 0; i < n; i++) {
            if(pixel == oldColors[i]) {
                return newColors[i] * color;
            }
        }

        return pixel * color;
    }   
]]

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