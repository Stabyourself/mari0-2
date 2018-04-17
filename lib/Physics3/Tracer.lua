local Tracer = class("Physics3.Tracer")

function Tracer:initialize(physObj, xOff, yOff, xDir, yDir, distance)
	self.physObj = physObj
	self.xOff = xOff
	self.yOff = yOff
	self.xDir = xDir
	self.yDir = yDir
	self.distance = distance
end

function Tracer:trace()
	local x, y, col
	
	for i = 0, self.distance-1 do
		local objX = self.physObj:getX()
		local objY = self.physObj:getY()

		if self.xDir > 0 then
			objX = math.ceil(objX)
		elseif self.xDir < 0 then
			objX = math.floor(objX)
		end

		if self.yDir > 0 then
			objY = math.ceil(objY)
		elseif self.yDir < 0 then
			objY = math.floor(objY)
		end

		x = objX + self.xOff + i*self.xDir
		y = objY + self.yOff + i*self.yDir
		
		col = self.physObj.World:checkMapCollision(x, y, self.physObj)
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

	love.graphics.rectangle("fill", self.physObj:getX() + xOff, self.physObj:getY() + yOff, xWidth, yWidth)
end

return Tracer