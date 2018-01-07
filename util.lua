-- I'd like to dedicate this file to stackoverflow.

local VARIABLES = require "variables"

local fileInfo = love.filesystem.getInfo("environment.lua")

if fileInfo and fileInfo.type == "file" then
    local envTemp = require "environment"
    
    for i, v in pairs(envTemp) do
        VARIABLES[i] = v
    end
end

function VAR(i, default)
    return VARIABLES[i] == nil and default or VARIABLES[i]
end

function CHEAT(i)
    return CHEATENABLED[i]
end

function print_r (t, name, indent) -- Credits to http://www.hpelbers.org/lua/print_r
    local tableList = {}
    function table_r (t, name, indent, full)
      local id = not full and name
          or type(name)~="number" and tostring(name) or '['..name..']'
      local tag = indent .. id .. ' = '
      local out = {}	-- result
      if type(t) == "table" then
        if tableList[t] ~= nil then table.insert(out, tag .. '{} -- ' .. tableList[t] .. ' (self reference)')
        else
          tableList[t]= full and (full .. '.' .. id) or id
          if next(t) then -- Table not empty
            table.insert(out, tag .. '{')
            for key,value in pairs(t) do 
              table.insert(out,table_r(value,key,indent .. '|  ',tableList[t]))
            end 
            table.insert(out,indent .. '}')
          else table.insert(out,tag .. '{}') end
        end
      else 
        local val = type(t)~="number" and type(t)~="boolean" and '"'..tostring(t)..'"' or tostring(t)
        table.insert(out, tag .. val)
      end
      return table.concat(out, '\n')
    end
    print(table_r(t,name or 'Value',indent or ''))
end

function string:split(delimiter) -- Credits to https://stackoverflow.com/a/5032014
	local result = {}
	local from = 1
	local delim_from, delim_to = string.find(self, delimiter, from, true)
	while delim_from do
		table.insert(result, string.sub(self, from, delim_from-1))
		from = delim_to + 1
		delim_from, delim_to = string.find(self, delimiter, from, true)
	end
	table.insert(result, string.sub(self, from))
	return result
end

function padZeroes(s, num)
    return string.format("%0" .. num .. "d", s)
end

function inTable(t, needle)
	for i, v in pairs(t) do
		if v == needle then
			return i
		end
	end
	return false
end

function math.round(i, decimals)
    local factor = math.pow(10, decimals or 0)
    
    if i >= 0 then
        return math.floor(i*factor+.5)/factor
    else
        return math.ceil(i*factor-.5)/factor
    end
end

function getRequiredSpeed(height, gravity)
    return math.sqrt(2*(gravity or VAR("gravity"))*height)
end

function math.clamp(n, low, high) 
    return math.max(math.min(high, n), low) 
end

function sideOfLine(ox, oy, p1x, p1y, p2x, p2y) -- Credits to https://stackoverflow.com/a/293052
    return (p2y-p1y)*ox + (p1x-p2x)*oy + (p2x*p1y-p1x*p2y)
end

function rectangleOnLine(x, y, w, h, p1x, p1y, p2x, p2y) -- See above
    -- A
    local xr = x+w -- right side
    local yb = y+h -- bottom side

    local pointPositions = {
        sideOfLine(x, y, p1x, p1y, p2x, p2y),
        sideOfLine(xr, y, p1x, p1y, p2x, p2y),
        sideOfLine(x, yb, p1x, p1y, p2x, p2y),
        sideOfLine(xr, yb, p1x, p1y, p2x, p2y),
    }

    local above, below = false, false

    for i = 1, 4 do
        if pointPositions[i] > 0 then
            above = true
        elseif pointPositions[i] < 0 then
            below = true
        end
    end

    if above and below then
        -- B
        if  (p1x > xr and p2x > xr) or
            (p1x < x and p2x < x) or
            (p1y > yb and p2y > yb) or
            (p1y < y and p2y < y) then
                return false
        else
            return true
        end
    end

    return false
end

function pointOnLine(lx1, ly1, lx2, ly2, px, py) -- Credits to https://stackoverflow.com/a/17693146
    local dist1P = math.sqrt((lx1-px)^2+(ly1-py)^2)
    local dist2P = math.sqrt((lx2-px)^2+(ly2-py)^2)
    local dist12 = math.sqrt((lx1-lx2)^2+(ly1-ly2)^2)
    
    if math.abs(math.abs(dist2P - dist1P) - dist12) < 0.0000001 or
        math.abs(math.abs(dist2P + dist1P) - dist12) < 0.0000001 then
        return dist1P - dist2P
    end
    return 
end

-- function pointOnLine(l1x, l1y, l2x, l2y, px, py)
--     if l1x == px then 
--         return l2x == px 
--     end
    
--     if l1y == py then
--         return l2y == py 
--     end
    
--     return math.abs((l1x - px)*(l1y - py) - (px - l2x)*(py - l2y)) < 0.000001
-- end

function objectWithinPortalRange(p, x, y)
    local nX, nY = pointAroundPoint(x, y, p.x1, p.y1, -p.angle)
    
    return nX-p.x1 > 0 and nX-p.x1 < p.size and nY < p.y1
end

function linesIntersect(p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y) -- Credits to https://stackoverflow.com/a/1968345
    local s0x = p2x - p1x 
    local s0y = p2y - p1y

    local s2_x = p4x - p3x  
    local s2_y = p4y - p3y

    local s = (-s0y * (p1x - p3x) + s0x * (p1y - p3y)) / (-s2_x * s0y + s0x * s2_y)
    local t = ( s2_x * (p1y - p3y) - s2_y * (p1x - p3x)) / (-s2_x * s0y + s0x * s2_y)

    if (s >= 0 and s <= 1 and t >= 0 and t <= 1) then
        return p1x + (t * s0x), p1y + (t * s0y)
    else
        return false
    end
end

function pointAroundPoint(x1, y1, x2, y2, r) -- Credits to https://stackoverflow.com/a/15109215
    local cos = math.cos(r)
    local sin = math.sin(r)

    return cos * (x1-x2) - sin * (y1-y2) + x2, sin * (x1-x2) + cos * (y1-y2) + y2
end

function pointInTriangle(x, y, t) -- Credits to https://stackoverflow.com/questions/2049582/how-to-determine-if-a-point-is-in-a-2d-triangle#comment22628102_2049712
    local A = 0.5 * (-t[4] * t[5] + t[2] * (-t[3] + t[5]) + t[1] * (t[4] - t[6]) + t[3] * t[6])
    local sign = A < 0 and -1 or 1
    local s = (t[2] * t[5] - t[1] * t[6] + (t[6] - t[2]) * x + (t[1] - t[5]) * y) * sign
    local t = (t[1] * t[4] - t[2] * t[3] + (t[2] - t[4]) * x + (t[3] - t[1]) * y) * sign

    return s > 0 and t > 0 and (s + t) < 2 * A * sign
end

function paletteSwap(imgData, swaps)
    for y = 0, imgData:getHeight()-1 do
        for x = 0, imgData:getWidth()-1 do
            for _, v in ipairs(swaps) do
                local r, g, b, a = imgData:getPixel(x, y)
                
                if r == v[1][1] and g == v[1][2] and b == v[1][3] then
                    imgData:setPixel(x, y, v[2][1], v[2][2], v[2][3], a)
                    
                    break
                end
            end
        end
    end
    
    return imgData
end

function normalizeAngle(a)
	a = math.fmod(a+math.pi, math.pi*2)-math.pi
    a = math.fmod(a-math.pi, math.pi*2)+math.pi
    
    return a
end