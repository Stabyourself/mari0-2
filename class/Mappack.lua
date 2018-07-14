local Level = require "class.Level"
local Mappack = class("Mappack")

function Mappack:initialize(name)
    self.name = name
    self.path = "mappacks/" .. name .. "/"

    self:loadSettings("settings.lua")
end

function Mappack:loadSettings(settingsPath)
    local settingsCode = love.filesystem.read(self.path .. settingsPath)
    self.settings = sandbox.run(settingsCode)
end

function Mappack:startLevel()
    return Level:new(self.path .. self.settings.main)
end

return Mappack
