-- Camera thing, written for Mari3  - MIT License.
local Camera = class("Camera")

function Camera:initialize()
	self.x = 0
	self.y = 0
end

function Camera:attach()
	love.graphics.push()
	love.graphics.translate(math.round(-self.x), math.round(-self.y))
end

function Camera:detach()
	love.graphics.pop()
end

return Camera