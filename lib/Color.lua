--[[

#########################################################################
#                                                                       #
# color.lua                                                             #
#                                                                       #
# Love2D color functions                                                #
#                                                                       #
# Copyright 2011 Josh Bothun                                            #
# joshbothun@gmail.com                                                  #
# http://minornine.com                                                  #
#                                                                       #
# This program is free software: you can redistribute it and/or modify  #
# it under the terms of the GNU General Public License as published by  #
# the Free Software Foundation, either version 3 of the License, or     #
# (at your option) any later version.                                   #
#                                                                       #
# This program is distributed in the hope that it will be useful,       #
# but WITHOUT ANY WARRANTY; without even the implied warranty of        #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
# GNU General Public License <http://www.gnu.org/licenses/> for         #
# more details.                                                         #
#                                                                       #
#########################################################################

--]]

-- Color functions
local color = {}

function color.toRgb(h, s, l, a)
    if s<=0 then return l,l,l,a end
    h, s, l = h/256*6, s/255, l/255
    local c = (1-math.abs(2*l-1))*s
    local x = (1-math.abs(h%2-1))*c
    local m,r,g,b = (l-.5*c), 0,0,0
    if h < 1     then r,g,b = c,x,0
    elseif h < 2 then r,g,b = x,c,0
    elseif h < 3 then r,g,b = 0,c,x
    elseif h < 4 then r,g,b = 0,x,c
    elseif h < 5 then r,g,b = x,0,c
    else              r,g,b = c,0,x
    end return (r+m)*255,(g+m)*255,(b+m)*255,a
end

function color.toHsl(r, g, b, a)
    local r, g, b = r/255, g/255, b/255
    local min, max = math.min(r, g, b), math.max(r, g, b)
    local h, s, l = 0, 0, (max + min) / 2
    if max ~= min then
        local d = max - min
        s = l > 0.5 and d / (2 - max - min) or d / (max + min)
        if max == r then
            local mod = 6
            if g > b then mod = 0 end
            h = (g - b) / d + mod
        elseif max == g then
            h = (b - r) / d + 2
        else
            h = (r - g) / d + 4
        end
    end
    h = h / 6
    return h*255, s*255, l*255, a
end

function color.shift(r, g, b, a, delta)
    if not delta then a, delta = delta, a end
    local h, s, l = color.toHsl(r, g, b)
    return color.toRgb((h + delta) % 255, s, l, a)
end

function color.lighten(r, g, b, a, delta)
    if not delta then a, delta = delta, a end

    if delta < 0 then
        return color.darken(r, g, b, a, -delta)
    end

    local h, s, l = color.toHsl(r, g, b)
    return color.toRgb(h, s, l+(255-l)*delta, a)
end

function color.saturate(r, g, b, a, delta)
    if not delta then a, delta = delta, a end
    local h, s, l = color.toHsl(r, g, b)

    if delta < 0 then
        return color.desaturate(r, g, b, a, -delta)
    end

    return color.toRgb(h, s+(255-s)*delta, l, a)
end

function color.darken(r, g, b, a, delta)
    if not delta then a, delta = delta, a end

    if delta < 0 then
        return color.lighten(r, g, b, a, -delta)
    end

    local h, s, l = color.toHsl(r, g, b)
    return color.toRgb(h, s, l-l*delta, a)
end

function color.desaturate(r, g, b, a, delta)
    if not delta then a, delta = delta, a end

    if delta < 0 then
        return color.saturate(r, g, b, a, -delta)
    end

    local h, s, l = color.toHsl(r, g, b)
    return color.toRgb(h, s-s*delta, l, a)
end

function constrain(i, min, max)
	return math.min(math.max(i, min), max)
end


-- Wrap all color methods to accept either a table or flat args
for k, v in pairs(color) do
    color[k] = function(a, b, c, d, ...)
        if type(a) == 'table' then
            return v(a[1], a[2], a[3], a[4], b, c, d, ...)
        end
        return v(a, b, c, d, ...)
    end
end

return color