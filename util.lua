-- I'd like to dedicate this file to stackoverflow.

local VARIABLES = require "variables"

assert(love.filesystem.getInfo("environment.lua"), "Missing environment. You need to copy environment.example.lua to environment.lua")

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
        elseif t.isInstanceOf and indent ~= '' then table.insert(out, tag .. tostring(t))
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

function inTable(t, needle)
	for i, v in pairs(t) do
		if v == needle then
			return i
		end
	end
	return false
end

function inITable(t, needle)
	for i, v in ipairs(t) do
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

function math.sign(i)
    if i > 0 then
        return 1
    elseif i < 0 then
        return -1
    else
        return 0
    end
end

function getRequiredSpeed(height, gravity) -- I don't think this is working right
    return math.sqrt(2*(gravity or VAR("gravity"))*height)
end

function math.clamp(n, low, high)
    return math.max(math.min(high, n), low)
end

function sideOfLine(ox, oy, p1x, p1y, p2x, p2y) -- Credits to https://stackoverflow.com/a/293052
    return (p2y-p1y)*ox + (p1x-p2x)*oy + (p2x*p1y-p1x*p2y)
end

local pointPositions = {}

function rectangleOnLine(x, y, w, h, p1x, p1y, p2x, p2y) -- See above
    -- A
    local xr = x+w -- right side
    local yb = y+h -- bottom side

    pointPositions[1] = sideOfLine(x, y, p1x, p1y, p2x, p2y)
    pointPositions[2] = sideOfLine(xr, y, p1x, p1y, p2x, p2y)
    pointPositions[3] = sideOfLine(x, yb, p1x, p1y, p2x, p2y)
    pointPositions[4] = sideOfLine(xr, yb, p1x, p1y, p2x, p2y)

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

    return s >= 0 and t >= 0 and (s + t) <= 2 * A * sign
end

function intersectRectangles(x1, y1, w1, h1, x2, y2, w2, h2)
    local x, y, w, h

    x = math.max(x1, x2)
    y = math.max(y1, y2)
    w = math.min(x1+w1, x2+w2) - math.max(x1, x2)
    h = math.min(y1+h1, y2+h2) - math.max(y1, y2)

    if w < 0 or h < 0 then
        return false
    end

    return x, y, w, h
end

function normalizeAngle(a)
	a = math.fmod(a+math.pi, math.pi*2)-math.pi
    a = math.fmod(a-math.pi, math.pi*2)+math.pi

    return a
end

local function combineTableCallRecursive(var, t)
    local ct = table.remove(t, 1)

    if #t == 0 then
        return var[ct]
    else
        return combineTableCallRecursive(var[ct], t)
    end
end

function combineTableCall(var, s) -- basically makes var["some.dot.separated.string"] into var.some.dot.separated.string
    return combineTableCallRecursive(var, s:split("."))
end

function getTileBorders(tiles, offsetX, offsetY)
    offsetX = offsetX or 0
    offsetY = offsetY or 0

    local borders = {}
    local SBL = {} -- selectionBordersLookup

    for _, tile in ipairs(tiles) do
        local x, y = tile[1], tile[2]

        if SBL[x-1] and SBL[x-1][y] and SBL[x-1][y].right then
            SBL[x-1][y].right = false
        end
        if SBL[x+1] and SBL[x+1][y] and SBL[x+1][y].left then
            SBL[x+1][y].left = false
        end
        if SBL[x] and SBL[x][y-1] and SBL[x][y-1].bottom then
            SBL[x][y-1].bottom = false
        end
        if SBL[x] and SBL[x][y+1] and SBL[x][y+1].top then
            SBL[x][y+1].top = false
        end

        if not SBL[x] then
            SBL[x] = {}
        end

        SBL[x][y] = {
            top = true,
            left = true,
            right = true,
            bottom = true
        }

        if SBL[x-1] and SBL[x-1][y] then
            SBL[x][y].left = false
        end
        if SBL[x+1] and SBL[x+1][y] then
            SBL[x][y].right = false
        end
        if SBL[x] and SBL[x][y-1] then
            SBL[x][y].top = false
        end
        if SBL[x] and SBL[x][y+1] then
            SBL[x][y].bottom = false
        end
    end

    for _, tile in ipairs(tiles) do
        local x, y = tile[1], tile[2]
        local wx, wy = (x-1+offsetX)*16, (y-1+offsetY)*16

        if SBL[x][y].top then
            table.insert(borders, {wx, wy, 0})
        end

        if SBL[x][y].right then
            table.insert(borders, {wx+16, wy, math.pi*.5})
        end

        if SBL[x][y].bottom then
            table.insert(borders, {wx+16, wy+16, math.pi})
        end

        if SBL[x][y].left then
            table.insert(borders, {wx, wy+16, -math.pi*.5})
        end
    end

    return borders
end

function convertPalette(palette)
    local out = {}

    for i, color in ipairs(palette) do
        out[i] = {}

        for j, channel in ipairs(color) do
            out[i][j] = channel/255
        end

        if not out[i][4] then
            out[i][4] = 1
        end
    end

    return out
end

function recursiveEnumerate(folder, files) -- What's with all the recursion in this project? smh
    if not files then
        files = {}
    end

    local filesTable = love.filesystem.getDirectoryItems(folder)

	for i,v in ipairs(filesTable) do
        local file = folder.."/"..v

        local fileInfo = love.filesystem.getInfo(file)

		if fileInfo.type == "file" then
			table.insert(files, file)
		elseif fileInfo.type == "directory" then
			recursiveEnumerate(file, files)
		end
    end

	return files
end

function clearTable(t)
    for k in pairs (t) do
        t[k] = nil
    end
end

function iClearTable(t)
    for k in pairs (t) do
        t[k] = nil
    end
end

function pointInRectangle(x, y, rx, ry, rw, rh)
    return x >= rx and y >= ry and x < rx+rw and y < ry+rh
end

function tilesInLine(x1, y1, x2, y2) -- Mostly copied from https://github.com/kikito/bresenham.lua
    local tiles = {}
    local sx,sy,dx,dy

    if x1 < x2 then
        sx = 1
        dx = x2 - x1
    else
        sx = -1
        dx = x1 - x2
    end

    if y1 < y2 then
        sy = 1
        dy = y2 - y1
    else
        sy = -1
        dy = y1 - y2
    end

    local err, e2 = dx-dy, nil

    table.insert(tiles, {x1, y1})

    while x1 ~= x2 or y1 ~= y2 do
        e2 = err + err
        if e2 > -dy then
            err = err - dy
            x1  = x1 + sx
        end
        if e2 < dx then
            err = err + dx
            y1  = y1 + sy
        end

        table.insert(tiles, {x1, y1})
    end

    return tiles
end

function componentAssert(component, condition, s)
    if not condition then
        local errstring = string.format([[%s
        actorTemplate %s]],
        s,
        component.actor and component.actor.actorTemplate.name or "unknown")

        error(errstring)
    end
end

-- this is really bad and only works for what I am doing with it
local function escapeStr(str)
    return str:gsub("\\", "\\\\")
end

function dumpTable(obj, indent)
    local oneIndent = "    "
    indent = indent or ""
    if type(obj) == "string" then
        return '"' .. escapeStr(obj) .. '"'
    elseif type(obj) == "number" then
        return tostring(obj)
    elseif obj == nil then
        return "nil"
    elseif type(obj) == "boolean" then
        return obj and "true" or "false"
    elseif type(obj) == "table" then
        local s = "{\n"
        for k, v in pairs(obj) do
            s = s .. indent .. oneIndent .. '[' .. dumpTable(k) .. '] = ' ..
                dumpTable(v, indent .. oneIndent) .. ",\n"
        end
        s = s .. indent .. "}"
        return s
    else
        print("Cannot serialize", type(obj))
    end
end

function compact(t)
    local out = {}

    for i = 1, #t do
        out[t[i]] = _G[t[i]]
    end

    return out
end

function intersectTiles(aTiles, bTiles)
    local newTiles = {}

    for _, bTile in ipairs(bTiles) do
        local found = false

        for _, aTile in ipairs(aTiles) do
            if bTile[1] == aTile[1] and bTile[2] == aTile[2] then
                found = true
                break
            end
        end

        if found then
            table.insert(newTiles, bTile)
        end
    end

    return newTiles
end
