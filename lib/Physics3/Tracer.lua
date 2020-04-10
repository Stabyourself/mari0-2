local Tracer = class("Physics3.Tracer") -- The cavalry is here

function Tracer:initialize(physObj, x, y, vector)
	self.physObj = physObj
	self.x = x
	self.y = y
	self.vector = vector
	self.vectorNormalized = self.vector:normalized()
	self.len = self.vector:len()
	self.tracedLength = 0

	self:cacheCoordinates()
end

function Tracer:cacheCoordinates()
	self.coordinateCache = {}

	for i = 1, self.len do
		local x = self.x + self.vectorNormalized.x*i
		local y = self.y + self.vectorNormalized.y*i

		self.coordinateCache[i] = {x, y}
	end
end

function Tracer:trace()
	local i = 1

	while i <= self.len do
		local x = self.coordinateCache[i][1] + self.physObj.x
		local y = self.coordinateCache[i][2] + self.physObj.y

		local xRounded, yRounded

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

		local col = self.physObj.world:checkCollision(xRounded, yRounded, self.physObj, self.vectorNormalized)
		if col then
			self.tracedLength = i
			return xRounded, yRounded, col
		end

		i = i + 1
	end
	self.tracedLength = self.len
end

function Tracer:debugDraw()
	local angle = self.vector:angleTo()

	local x = self.x
	local y = self.y

	x = x + self.physObj.x
	y = y + self.physObj.y

	x = math.floor(x)
	y = math.floor(y)

	love.graphics.push()
	love.graphics.translate(x+.5, y+.5)
	love.graphics.rotate(angle)

	love.graphics.rectangle("fill", -.5, -.5, self.len, 1)
	if VAR("debug").tracerDebug then
		local r, g, b, a = love.graphics.getColor()

		love.graphics.setColor(1, 0, 0)
		love.graphics.rectangle("fill", -.5, -.5, self.tracedLength, 1)

		love.graphics.setColor(r, g, b, a)
	end

	love.graphics.pop()
end

return Tracer