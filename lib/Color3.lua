-- Color library thing for Mari0 2. Feel free to use it, MIT License

local Color = class("Color")

function Color.fromRGB(r, g, b, a)
    return Color:new(r, g, b, a or 1)
end

function Color.fromHSV(h, s, v, a)
    return Color:new(Color.HSVtoRGB(h, s, v, a or 1))
end

function Color:initialize(r, g, b, a)
    self.r = r
    self.g = g
    self.b = b
    self.a = a
end

function Color:rgb()
    return self.r, self.g, self.b, self.a
end

function Color:table()
    return {self.r, self.g, self.b, self.a}
end

function Color:darken(i)
    local h, s, v, a = Color.RGBtoHSV(self.r, self.g, self.b, self.a)

    v = (1-i)*v

    return Color.HSVtoRGB(h, s, v, a)
end

function Color:lighten(i)
    local h, s, v, a = Color.RGBtoHSV(self.r, self.g, self.b, self.a)

    s = (1-i)*s

    return Color.HSVtoRGB(h, s, v, a)
end

function Color.HSVtoRGB(h, s, v, a)
    local i = math.floor(h * 6);
    local f = h * 6 - i;
    local p = v * (1 - s);
    local q = v * (1 - f * s);
    local t = v * (1 - (1 - f) * s);

    local mod = i % 6

    local r, g, b

    if mod == 0 then
        r, g, b = v, t, p
    elseif mod == 1 then
        r, g, b = q, v, p
    elseif mod == 2 then
        r, g, b = p, v, t
    elseif mod == 3 then
        r, g, b = p, q, v
    elseif mod == 4 then
        r, g, b = t, p, v
    elseif mod == 5 then
        r, g, b = v, p, q
    end

    return r, g, b, a
end

function Color.RGBtoHSV(r, g, b, a)
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local h, v = max, max

    local d = max - min
    local s = (max == 0) and 0 or d / max

    if max == min then
        h = 0
    else
        if max == r then
            h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then
            h = (b - r) / d + 2
        elseif max == b then
            h = (r - g) / d + 4
        end
        h = h/6
    end

    return h, s, v, a
end

return Color