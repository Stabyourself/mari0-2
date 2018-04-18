local PhysObj = class("Physics3.PhysObj")

function PhysObj:initialize(world, x, y, width, height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.world = world
	
	self.speed = {0, 0}
	
	self.gravityDirection = math.pi*.5
	
	self.angle = 0
	
    self.surfaceAngle = 0
	self.onGround = false
	
	self.tracers = {}
	self.tracers.left = {}
	self.tracers.right = {}
	self.tracers.up = {}
	self.tracers.down = {}
	
	-- register yourself with the world
	world:addObject(self)
	
	local xOff, yOff, distance
	local step = self.world.tileSize
	
	-- Create left tracers
	xOff = math.floor(self.width/2)-1
	distance = math.floor(self.width/2)
	
	for yOff = self.height - Physics3.TRACER_BOTTOM_DIST - 1, Physics3.TRACER_SIDE_TOP_DIST+1, -step do
		table.insert(self.tracers.left, Physics3.Tracer:new(self, xOff, yOff, -1, 0, distance))
	end
	
	-- Also include almost top
	table.insert(self.tracers.left, Physics3.Tracer:new(self, xOff, Physics3.TRACER_SIDE_TOP_DIST, -1, 0, distance))
	
	
	-- Create right tracers
	xOff = math.floor(self.width/2)
	distance = math.floor(self.width/2)
	
	for yOff = self.height - Physics3.TRACER_BOTTOM_DIST - 1, Physics3.TRACER_SIDE_TOP_DIST+1, -step do
		table.insert(self.tracers.right, Physics3.Tracer:new(self, xOff, yOff, 1, 0, distance))
	end
	
	-- Also include almost top
	table.insert(self.tracers.right, Physics3.Tracer:new(self, xOff, Physics3.TRACER_SIDE_TOP_DIST, 1, 0, distance))
	
	
	-- Create bottom tracers
	yOff = self.height/2
	distance = self.height/2+Physics3.TRACER_BOTTOM_EXTEND
	
	--from left side
	for xOff = 0+Physics3.TRACER_BOTTOM_SIDE_SPACING, math.floor(self.width/2)-1, Physics3.TRACER_BOTTOM_SPACING do
		table.insert(self.tracers.down, Physics3.Tracer:new(self, xOff, yOff, 0, 1, distance))
	end
	
	--from right side
	for xOff = self.width-1-Physics3.TRACER_BOTTOM_SIDE_SPACING, math.floor(self.width/2), -Physics3.TRACER_BOTTOM_SPACING do
		table.insert(self.tracers.down, Physics3.Tracer:new(self, xOff, yOff, 0, 1, distance))
	end
	
	
	-- Create top tracers
	yOff = self.height/2-1
	distance = self.height/2
	
	--from left side
	for xOff = 0+Physics3.TRACER_TOP_SPACING, math.floor(self.width/2)-1, step do
		table.insert(self.tracers.up, Physics3.Tracer:new(self, xOff, yOff, 0, -1, distance))
	end
	
	--from right side
	for xOff = self.width-1-Physics3.TRACER_TOP_SPACING, math.floor(self.width/2), -step do
		table.insert(self.tracers.up, Physics3.Tracer:new(self, xOff, yOff, 0, -1, distance))
	end
end

function PhysObj:unRotate(dt)
	self.angle = normalizeAngle(self.angle)
	
	if self.angle > 0 then
		self.angle = math.max(0, self.angle - VAR("rotationSpeed")*dt)
	else
		self.angle = math.min(0, self.angle + VAR("rotationSpeed")*dt)
	end
end

function PhysObj:leftColCheck()
	local colX, colY

	for _, tracer in ipairs(self.tracers.left) do
		local currentTraceX, currentTraceY = tracer:trace()
		
		if currentTraceX and (not col or currentTraceX > col) then
			colX, colY = currentTraceX, currentTraceY
		end
	end
	
	if colX then --Left collision
		if not self:leftCollision() then
			self.x = colX+1
			self.speed[1] = math.max(self.speed[1], 0)
			return colX, colY
		end
	end
	
	return false
end

function PhysObj:rightColCheck()
	local colX, colY

	for _, tracer in ipairs(self.tracers.right) do
		local currentTraceX, currentTraceY = tracer:trace()
		
		if currentTraceX and (not col or currentTraceX < col) then
			colX, colY = currentTraceX, currentTraceY
		end
	end
	
	if colX then --Right collision
		if not self:rightCollision() then
			self.x = colX-self.width
			self.speed[1] = math.min(self.speed[1], 0)
			return colX, colY
		end
	end
	
	return false
end

function PhysObj:topColCheck()
	local colX, colY
	
	for _, tracer in ipairs(self.tracers.up) do
		local currentTraceX, currentTraceY = tracer:trace()
		
		if currentTraceX and (not colX or currentTraceY > colY) then
			colX, colY = currentTraceX, currentTraceY
		end
	end
	
	if colY then --Top collision
		if not self:topCollision() then
			self.y = colY+1
			self.speed[2] = math.max(self.speed[2], 0)
			
			return colX, colY
		end
	end
	
	return false
end

function PhysObj:bottomColCheck()
	local colX, colY
	
	for _, tracer in ipairs(self.tracers.down) do
		local currentTraceX, currentTraceY = tracer:trace()
		
		if currentTraceX and (not colX or currentTraceY < colY) then
			colX, colY = currentTraceX, currentTraceY
		end
	end
	
	if colY then --Ground collision
		if self.onGround or colY <= self.y + self.height then
			if not self:bottomCollision(nil) then
				if not self.onGround then
					self.onGround = true
				end
				
				self.y = colY-self.height
				self.speed[2] = math.min(self.speed[2], 0)
				
				return colX, colY
			end
		end
	end
	
	return false
end

local col = {
	left = {},
	right = {},
	top = {},
	bottom = {}
}

function PhysObj:checkCollisions()
	col.left[1], col.left[2] = self:leftColCheck()

	col.right[1] = nil
	if not col.left[1] then
		col.right[1], col.right[2] = self:rightColCheck()
	end
	
	col.bottom[1] = nil
	if self.speed[2] > 0 then
		col.bottom[1], col.bottom[2] = self:bottomColCheck()
	end
	
	if not col.bottom[1] then
		col.top[1], col.top[2] = self:topColCheck()
		
		if self.onGround and self.speed[2] > 0 then
			self:startFall()
			self.onGround = false
		end
	end
	
	if col.bottom[1] then
		local x, y = self.world:worldToMap(col.bottom[1], col.bottom[2])
		
		local tile = self.world:getTile(x, y)
		
		if tile then
			self.surfaceAngle = tile.angle -- todo: May be wrong if colliding pixel is right underneath a slope's end!
		end
	end
end

function PhysObj:debugDraw(xOff, yOff)
	love.graphics.setColor(1, 0, 0)
	love.graphics.rectangle("line", self.x+.5, self.y+.5, self.width-1, self.height-1)
	
	love.graphics.setColor(0, 1, 0, 0.5)
	for j, w in ipairs(self.tracers.right) do
		w:debugDraw()
	end
	
	love.graphics.setColor(0, 0, 1, 0.5)
	for j, w in ipairs(self.tracers.left) do
		w:debugDraw()
	end
	
	love.graphics.setColor(1, 0, 1, 0.5)
	for j, w in ipairs(self.tracers.down) do
		w:debugDraw()
	end
	
	love.graphics.setColor(1, 1, 0, 0.5)
	for j, w in ipairs(self.tracers.up) do
		w:debugDraw()
	end
	
	love.graphics.setColor(1, 1, 1)
end

function PhysObj:leftCollision() end
function PhysObj:rightCollision() end
function PhysObj:bottomCollision() end
function PhysObj:topCollision() end
function PhysObj:startFall() end

return PhysObj