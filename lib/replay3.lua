local serialize = require "lib.serialize"

local recordKeys = {"a", "s", "d", "w", "lshift", "space"}
local recordMouse = true

local replay3 = {}

function replay3.init()
    replay3.movie = {}
    replay3.frame = 1
    replay3.timeElapsed = 0
    replay3.keyStates = {}

    FrameDebug3.pause()

    if VAR("replayState") == "playing" then
        replay3.movie = require "replay"

        -- overwrite controls3.cmdDown
        function controls3.cmdDown(cmd)
            local keys = controls3.cmdTableLookup[cmd]

            for _, key in ipairs(keys) do
                for _, keyDown in ipairs(replay3.movie[replay3.frame].keys) do
                    if key == keyDown then
                        return true
                    end
                end
            end

            return false
        end

        -- overwrite mouse getX, getY, getPosition
        function love.mouse.getX()
            return replay3.movie[replay3.frame].mouse.x
        end

        function love.mouse.getY()
            return replay3.movie[replay3.frame].mouse.y
        end

        function love.mouse.getPosition()
            return replay3.movie[replay3.frame].mouse.x, replay3.movie[replay3.frame].mouse.y
        end
    end
end

-- playback

function replay3.update(dt)
    if boop and VAR("replayState") == "playing" then
        -- something about frametimes
        replay3.timeElapsed = replay3.timeElapsed + dt

        while replay3.timeElapsed > 1/60 do
            replay3.timeElapsed = replay3.timeElapsed - 1/60
            replay3.frame = math.min(#replay3.movie, replay3.frame + 1)

            FrameDebug3.frameAdvance()

            local frame = replay3.movie[replay3.frame]

            -- fire keypressed events
            for _, key in ipairs(frame.keys) do
                if not replay3.keyStates[key] then
                    love.event.push("keypressed", key)

                    replay3.keyStates[key] = true
                end
            end

            -- clear keyStates of non-pressed keys
            for keyStateName, keyState in pairs(replay3.keyStates) do
                local keyState = replay3.keyStates[i]

                local found = false

                for _, key in ipairs(frame.keys) do
                    if key == keyStateName then
                        found = true
                    end
                end

                if not found then
                    replay3.keyStates[keyStateName] = false
                end
            end

            -- fire mouse events
            for _, button in ipairs(frame.mouse.buttons) do
                love.event.push("mousepressed", frame.mouse.x, frame.mouse.y, button)
            end
        end
    end
end


--recording
function replay3.storeFrame()
    local frame = {
        keys = {},
    }

    -- keys
    for _, key in ipairs(recordKeys) do
        if love.keyboard.isDown(key) then
            local change = true

            table.insert(frame.keys, key)
        end
    end

    -- mouse
    if recordMouse then
        frame.mouse = {
            buttons={}
        }

        frame.mouse.x = love.mouse.getX()
        frame.mouse.y = love.mouse.getY()

        for i = 1, 3 do
            if love.mouse.isDown(i) then
                table.insert(frame.mouse.buttons, i)
            end
        end
    end

    table.insert(replay3.movie, frame)
end

function replay3.save()
    love.filesystem.write("replay.lua", serialize.tstr(replay3.movie))
end

return replay3
