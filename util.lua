local VARIABLES = require "variables"

if love.filesystem.exists("environment.lua") then
    local envTemp = require "environment"
    
    for i, v in pairs(envTemp) do
        VARIABLES[i] = v
    end
end

function VAR(i, default)
    return VARIABLES[i] or default
end

function print_r (t, name, indent) -- http://www.hpelbers.org/lua/print_r
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

function padZeroes(s, num)
    return string.format("%0" .. num .. "d", s)
end

function inTable(t, needle)
	for i, v in pairs(t) do
		if v == needle then
			return true
		end
	end
	return false
end

function math.round(i, decimals)
    local factor = math.pow(10, decimals or 0)
    
    if i > 0 then
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

function rectangleOnLine(x, y, w, h, p1x, p1y, p2x, p2y) -- Todo: optimize this
    -- A
    local pointPositions = {
        sideOfLine(x, y, p1x, p1y, p2x, p2y),
        sideOfLine(x+w, y, p1x, p1y, p2x, p2y),
        sideOfLine(x, y+h, p1x, p1y, p2x, p2y),
        sideOfLine(x+w, y+h, p1x, p1y, p2x, p2y)
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
        local angle = math.atan2(p2y-p1y, p2x-p1x)
        local newX = pointAroundPoint(x, y, p1x, p1y, -angle) - p1x
        
        if newX > -0.1 and newX < 1.9 then -- These values may need to be reworked properly
            return true
        end
    end

    return false
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
    end

    return false
end

function pointAroundPoint(x1, y1, x2, y2, r) -- Credits to https://stackoverflow.com/a/15109215
    local newX = math.cos(r) * (x1-x2) - math.sin(r) * (y1-y2) + x2
    local newY = math.sin(r) * (x1-x2) + math.cos(r) * (y1-y2) + y2

    return newX, newY
end

function pointInTriangle(x, y, t) -- Credits to https://stackoverflow.com/questions/2049582/how-to-determine-if-a-point-is-in-a-2d-triangle#comment22628102_2049712
    local A = 0.5 * (-t[4] * t[5] + t[2] * (-t[3] + t[5]) + t[1] * (t[4] - t[6]) + t[3] * t[6])
    local sign = A < 0 and -1 or 1
    local s = (t[2] * t[5] - t[1] * t[6] + (t[6] - t[2]) * x + (t[1] - t[5]) * y) * sign
    local t = (t[1] * t[4] - t[2] * t[3] + (t[2] - t[4]) * x + (t[3] - t[1]) * y) * sign

    return s >= 0 and t >= 0 and (s + t) < 2 * A * sign
end