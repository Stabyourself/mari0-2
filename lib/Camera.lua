-- Camera thing, written for Mari3  - MIT License.
local Camera = class("Camera")

function Camera:initialize()
	self.x = 0
	self.y = 0
end

function Camera:attach()
	love.graphics.push()
	if VAR("noSubpixelMovement") then
		love.graphics.translate(math.round(-self.x), math.round(-self.y))
	else
		love.graphics.translate(-self.x, -self.y)
	end
end

function Camera:detach()
	love.graphics.pop()
end

return Camera