local Camera = class("Camera")

function Camera:initialize()
	self.x = 0
	self.y = 0
end

function Camera:attach()
	love.graphics.push()
	love.graphics.translate(math.round(-self.x*TILESIZE), math.round(-self.y*TILESIZE))
end

function Camera:detach()
	love.graphics.pop()
end

return Camera