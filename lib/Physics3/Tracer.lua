local Tracer = class("Physics3.Tracer") -- The cavalry is here

function Tracer:initialize(physObj, x, y, vector)
	self.physObj = physObj
	self.x = x
	self.y = y
	self.vector = vector
	self.vectorNormalized = self.vector:normalized()
	self.len = self.vector:len()
	self.angle = self.physObj.angle
end

function Tracer:trace()
	local i = 1

	while i <= self.len do
		local x = self.x + self.vectorNormalized.x*i -- todo: these could be cached
		local y = self.y + self.vectorNormalized.y*i

		x, y = self.physObj.transform:transformPoint(x, y)

		x = x + self.physObj.x
		y = y + self.physObj.y

		xRounded = math.round(x)
		yRounded = math.round(y)

		col = self.physObj.World:checkCollision(xRounded, yRounded, self.physObj)
		if col then
			return x, y, col
		end

		i = i + 1
	end
end

function Tracer:debugDraw()
	local angle = self.vector:angleTo()

	local x = self.x
	local y = self.y

	x, y = self.physObj.transform:transformPoint(x, y)

	x = x + self.physObj.x
	y = y + self.physObj.y

	-- x = math.round(x)
	-- y = math.round(y)

	love.graphics.push()
	love.graphics.translate(x, y)
	love.graphics.rotate(angle+self.angle)

	love.graphics.rectangle("fill", 0, -.5, self.len, 1)
	love.graphics.pop()
end

return Tracer