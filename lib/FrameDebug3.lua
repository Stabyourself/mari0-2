-- Debug thing for Mari0 2. Feel free to use it, MIT License

local FrameDebug3 = {}

local advanceDT = 1/60

local playing = true
local advanceFrame = false

local replay3 = require "lib.replay3"

function FrameDebug3.update(dt)
    local mul = 1

	if VAR("ffKeys") then
        for _, ffKey in ipairs(VAR("ffKeys")) do
			if love.keyboard.isDown(ffKey.key) then
				mul = mul * ffKey.val
			end
		end
    end

    if not playing then
        if advanceFrame then
            advanceFrame = false

            return advanceDT*mul
        else
            return false
        end
    end

    return dt*mul
end

function FrameDebug3.pausePlay()
    playing = not playing
end

function FrameDebug3.pause()
    playing = false
end

function FrameDebug3.frameAdvance()
    playing = false
    advanceFrame = true
    if VAR("replayState") == "recording" then
        replay3.storeFrame()
    end
end

return FrameDebug3
