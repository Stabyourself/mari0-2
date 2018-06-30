-- Controls library thing for Mari0 2. Feel free to use it, MIT License

local controls3 = {}
local cmds = {}

local function assignCmd(v, cmd)
    if controls3.cmdTableLookup[cmd] then
        table.insert(controls3.cmdTableLookup[cmd], v)
    else
        controls3.cmdTableLookup[cmd] = {v}
    end
end

function controls3.setCmdTable(t)
    controls3.cmdTable = t
    controls3.cmdTableLookup = {}

    -- generate the cmdDown lookup table
    for key, cmd in pairs(t) do
        if type(cmd) == "string" then
            assignCmd(key, cmd)
        elseif type(cmd) == "table" then
            for _, v in ipairs(cmd) do
                assignCmd(key, v)
            end
        end
    end
end

local function appendCmds(cmds, t)
    if type(t) == "string" then
        cmds[t] = true
    elseif type(t) == "table" then
        for _, v in ipairs(t) do
            cmds[v] = true
        end
    end
end

function controls3.getCmdsForKey(key)
    -- Convert the key to its binding
    -- ^ctrl !alt +shift

    for k in pairs (cmds) do
        cmds[k] = nil
    end

    local anyCmds = false

    if controls3.cmdTable[key] then
        appendCmds(cmds, controls3.cmdTable[key])
        anyCmds = true
    end

    appendCmds(cmds, controls3.cmdTable[key])

    local keyModified = key

    if  key ~= "lshift" and key ~= "rshift" and
        key ~= "lalt" and key ~= "ralt" and
        key ~= "lctrl" and key ~= "rctrl" then
        if love.keyboard.isDown({"lshift", "rshift"}) then
            keyModified = "+" .. keyModified
        end

        if love.keyboard.isDown({"lalt", "ralt"}) then
            keyModified = "!" .. keyModified
        end

        if love.keyboard.isDown({"lctrl", "rctrl"}) then
            keyModified = "^" .. keyModified
        end
    end

    if keyModified ~= key then
        if controls3.cmdTable[keyModified] then
            appendCmds(cmds, controls3.cmdTable[keyModified])
            anyCmds = true
        end
    end

    return cmds, anyCmds
end

-- ^ctrl !alt +shift
function controls3.cmdDown(cmd)
    local keys = controls3.cmdTableLookup[cmd]

    for _, key in ipairs(keys) do
        local pass = true

        local firstChar = string.sub(key, 1, 1)
        if firstChar == "^" then
            if not love.keyboard.isDown({"lctrl", "rctrl"}) then
                pass = false
            end
            key = string.sub(key, 2, -1)
        end

        local firstChar = string.sub(key, 1, 1)
        if firstChar == "!" then
            if not love.keyboard.isDown({"lalt", "ralt"}) then
                pass = false
            end
            key = string.sub(key, 2, -1)
        end

        local firstChar = string.sub(key, 1, 1)
        if firstChar == "+" then
            if not love.keyboard.isDown({"lshift", "rshift"}) then
                pass = false
            end
            key = string.sub(key, 2, -1)
        end

        if pass then
            if love.keyboard.isDown(key) then
                return true
            end
        end
    end

    return false
end

return controls3
