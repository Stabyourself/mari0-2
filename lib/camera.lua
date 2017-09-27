local Camera = class("Camera")

function Camera:initialize()
	self.x = 0
	self.y = 0
end

function Camera:attach()
	love.graphics.push()
	love.graphics.translate(math.floor(-self.x*TILESIZE), math.floor(-self.y*TILESIZE))
end

function Camera:detach()
	love.graphics.pop()
end

return Camera