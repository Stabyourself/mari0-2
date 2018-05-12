-- Debug thing for Mari0 2. Feel free to use it, MIT License

local FrameDebug3 = {}

local advanceDT = 1/60

local playing = true
local advanceFrame = false

function FrameDebug3.update(dt)
    if not playing then
        if advanceFrame then
            advanceFrame = false

            return advanceDT
        else
            return false
        end
    end

    return dt
end

function FrameDebug3.pausePlay()
    playing = not playing
end

function FrameDebug3.frameAdvance()
    playing = false
    advanceFrame = true
end

return FrameDebug3
