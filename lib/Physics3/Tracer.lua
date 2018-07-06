local Tracer = class("Physics3.Tracer") -- The cavalry is here

function Tracer:initialize(physObj, x, y, vector)
	self.physObj = physObj
	self.x = x
	self.y = y
	self.vector = vector
	self.vectorNormalized = self.vector:normalized()
	self.len = self.vector:len()
end

function Tracer:trace()
	local i = 1

	while i <= self.len do
		local x = self.x + self.physObj.x + self.vectorNormalized.x*i -- todo: these could be cached (definitely do this)
		local y = self.y + self.physObj.y + self.vectorNormalized.y*i

		if self.vector.y < 0 then -- don't ask me why
			yRounded = math.ceil(y)
		else
			yRounded = math.floor(y)
		end

		if self.vector.x < 0 then
			xRounded = math.ceil(x)
		else
			xRounded = math.floor(x)
		end

		col = self.physObj.world:checkCollision(xRounded, yRounded, self.physObj, self.vectorNormalized)
		if col then
			return xRounded, yRounded, col
		end

		i = i + 1
	end
end

function Tracer:debugDraw()
	local angle = self.vector:angleTo()

	local x = self.x+0.5
	local y = self.y+0.5

	x = x + self.physObj.x
	y = y + self.physObj.y

	x = math.round(x)
	y = math.round(y)

	love.graphics.push()
	love.graphics.translate(x, y)
	love.graphics.rotate(angle)

	love.graphics.rectangle("fill", 0, -.5, self.len, 1)
	love.graphics.pop()
end

return Tracer