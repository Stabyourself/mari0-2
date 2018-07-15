-- Color library thing for Mari0 2. Feel free to use it, MIT License

local Color = class("Color")

function Color.fromRGB(r, g, b, a)
    return Color:new(r, g, b, a or 1)
end

function Color.fromHSV(h, s, v, a)
    return Color:new(Color.HSVtoRGB(h, s, v, a or 1))
end

function Color.fromHSL(h, s, l, a)
    return Color:new(Color.HSLtoRGB(h, s, l, a or 1))
end

function Color:initialize(r, g, b, a)
    self.r = r
    self.g = g
    self.b = b
    self.a = a or 1
end

function Color:rgb()
    return self.r, self.g, self.b, self.a
end

function Color:table()
    return {self.r, self.g, self.b, self.a}
end

function Color:darken(i)
    local h, s, l, a = Color.RGBtoHSL(self.r, self.g, self.b, self.a)

    l = l*(1-i)

    return Color.HSLtoRGB(h, s, l, a)
end

function Color:lighten(i)
    local h, s, l, a = Color.RGBtoHSL(self.r, self.g, self.b, self.a)

    l = l + (1-l)*i

    return Color.HSLtoRGB(h, s, l, a)
end

function Color:fadeTo(color2, i)
    local r = self.r+(color2.r-self.r)*i
    local g = self.g+(color2.g-self.g)*i
    local b = self.b+(color2.b-self.b)*i
    local a = self.a+(color2.a-self.a)*i

    return r, g, b, a
end

local function hue2rgb(p, q, t)
    if t < 0 then t = t + 1 end
    if t > 1 then t = t - 1 end
    if t < 1/6 then return p + (q - p) * 6 * t end
    if t < 1/2 then return q end
    if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end

    return p
end

function Color.HSLtoRGB(h, s, l, a) -- https://stackoverflow.com/a/9493060
    local r, g, b

    if s == 0 then
        return l, l, l
    else
        local q

        if l < 0.5 then
            q = l * (1 + s)
        else
            q = l + s - l * s
        end

        local p = 2 * l - q
        r = hue2rgb(p, q, h + 1/3)
        g = hue2rgb(p, q, h)
        b = hue2rgb(p, q, h - 1/3)
    end

    return r, g, b, a
end

function Color.RGBtoHSL(r, g, b, a)
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)

    local h = (max + min) / 2
    local s = (max + min) / 2
    local l = (max + min) / 2

    if max == min then
        h = 0
        s = 0
    else
        local d = max - min

        if l > 0.5 then
            s = d / (2 - max - min)
        else
            s = d / (max + min)
        end

        if max == r then
            h = (g - b) / d

            if g < b then
                h = h + 6
            end

        elseif max == g then
            h = (b - r) / d + 2

        elseif max == b then
            h = (r - g) / d + 4
        end

        h = h / 6
    end

    return h, s, l, a
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