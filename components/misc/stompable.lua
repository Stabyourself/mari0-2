local Component = require "class.Component"
local stompable = class("misc.stompable", Component)

stompable.argList = {
    {"level", "number", 1},
}

return stompable
