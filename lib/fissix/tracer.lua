local Tracer = class("fissix.Tracer")

function Tracer:initialize(PhysObj, xOff, yOff, xDir, yDir, distance)
	self.PhysObj = PhysObj
	self.xOff = xOff
	self.yOff = yOff
	self.xDir = xDir
	self.yDir = yDir
	self.distance = distance
end

function Tracer:trace()
	local x, y, col
	
	for i = 0, self.distance-1 do
		x = self.PhysObj:getX() + self.xOff + i*self.xDir
		y = self.PhysObj:getY() + self.yOff + i*self.yDir
		
		col = self.PhysObj.World:checkMapCollision(x, y)
		if col then
			return x, y
		end
	end
end

function Tracer:debugDraw()
	local xWidth = self.xDir*self.distance
	local yWidth = self.yDir*self.distance
	local xOff = self.xOff
	local yOff = self.yOff
	
	if xWidth < 0 then
		xOff = xOff + 1
	elseif xWidth == 0 then
		xWidth = 1
	end
	
	if yWidth < 0 then
		yOff = yOff + 1
	elseif yWidth == 0 then
		yWidth = 1
	end

	love.graphics.rectangle("fill", self.PhysObj:getX() + xOff, self.PhysObj:getY() + yOff, xWidth, yWidth)
end

return Tracer