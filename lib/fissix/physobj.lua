local PhysObj = class("fissix.PhysObj")

function PhysObj:initialize(world, x, y, width, height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.world = world
	
	self.speedX = 0
	self.speedY = 0
	
	self.friction = 0
	
	self.onGround = false
	
	self.tracers = {}
	self.tracers.left = {}
	self.tracers.right = {}
	self.tracers.up = {}
	self.tracers.down = {}
	
	-- register yourself with the world
	world:addObject(self)
	
	local xOff, yOff, distance
	local step = self.world.tileMap.tileSize
	
	
	-- Create left tracers
	xOff = math.floor(self.width/2)-1
	distance = math.floor(self.width/2)
	
	for yOff = self.height - fissix.TRACER_BOTTOM_DIST - 1, fissix.TRACER_TOP_SPACE+1, -step do
		table.insert(self.tracers.left, fissix.Tracer:new(self, xOff, yOff, -1, 0, distance))
	end
	
	-- Also include almost top
	table.insert(self.tracers.left, fissix.Tracer:new(self, xOff, fissix.TRACER_TOP_SPACE, -1, 0, distance))
	
	
	-- Create right tracers
	xOff = math.floor(self.width/2)
	distance = math.floor(self.width/2)
	
	for yOff = self.height - fissix.TRACER_BOTTOM_DIST - 1, fissix.TRACER_TOP_SPACE+1, -step do
		table.insert(self.tracers.right, fissix.Tracer:new(self, xOff, yOff, 1, 0, distance))
	end
	
	-- Also include almost top
	table.insert(self.tracers.right, fissix.Tracer:new(self, xOff, fissix.TRACER_TOP_SPACE, 1, 0, distance))
	
	
	-- Create bottom tracers
	yOff = self.height/2
	distance = self.height/2+fissix.TRACER_DOWN_EXTEND
	
	--from left side
	for xOff = 0+fissix.TRACER_SIDE_DIST, math.floor(self.width/2)-1, fissix.TRACER_DOWN_SPACE do
		table.insert(self.tracers.down, fissix.Tracer:new(self, xOff, yOff, 0, 1, distance))
	end
	
	--from right side
	for xOff = self.width-1-fissix.TRACER_SIDE_DIST, math.floor(self.width/2), -fissix.TRACER_DOWN_SPACE do
		table.insert(self.tracers.down, fissix.Tracer:new(self, xOff, yOff, 0, 1, distance))
	end
	
	
	-- Create top tracers
	yOff = self.height/2-1
	distance = self.height/2
	
	--from left side
	for xOff = 0+fissix.TRACER_SIDE_DIST_TOP, math.floor(self.width/2)-1, step do
		table.insert(self.tracers.up, fissix.Tracer:new(self, xOff, yOff, 0, -1, distance))
	end
	
	--from right side
	for xOff = self.width-1-fissix.TRACER_SIDE_DIST_TOP, math.floor(self.width/2), -step do
		table.insert(self.tracers.up, fissix.Tracer:new(self, xOff, yOff, 0, -1, distance))
	end
end

function PhysObj:horCollisions()
	local colX, colY
	local currentTraceX, currentTraceY
	local collisions = {}

	--Left side
	colX, colY = false
	for i, v in ipairs(self.tracers.left) do
		local currentTraceX, currentTraceY = v:trace()
		
		if currentTraceX and (not col or currentTraceX > col) then
			colX, colY = currentTraceX, currentTraceY
		end
	end
	
	if colX then --Left collision
		if not self.leftCollision() then
			self.x = colX+1
			self.speedX = math.max(self.speedX, 0)
			collisions.left = true
		end
	end
	
	--Right side
	if not colX then
		for i, v in ipairs(self.tracers.right) do
			local currentTraceX, currentTraceY = v:trace()
			
			if currentTraceX and (not col or currentTraceX < col) then
				colX, colY = currentTraceX, currentTraceY
			end
		end
		
		if colX then --Right collision
			if not self.rightCollision() then
				self.x = colX-self.width
				self.speedX = math.min(self.speedX, 0)
				collisions.right = true
			end
		end
	end
end

function PhysObj:verCollisions()
	local colX, colY
	local currentTraceX, currentTraceY
	local collisions = {}
	local currentlyOnGround = self.onGround

	--Bottom
	if self.speedY > 0 then
		colX, colY = false
		for i, v in ipairs(self.tracers.down) do
			local currentTraceX, currentTraceY = v:trace()
			
			if currentTraceX and (not colX or currentTraceY < colY) then
				colX, colY = currentTraceX, currentTraceY
			end
		end
		
		
		if colY then --Ground collision
			if not self.bottomCollision() then
				if self.onGround then
					self.y = colY-self.height
					self.speedY = math.min(self.speedY, 0)
				else
					if colY <= self.y + self.height then
						self.y = colY-self.height
						self.speedY = math.min(self.speedY, 0)
						self.onGround = true
					end
				end
				collisions.down = true
			end
		end
	end
	
	--Top
	if not colX then
		for i, v in ipairs(self.tracers.up) do
			local currentTraceX, currentTraceY = v:trace()
			
			if currentTraceX and (not colX or currentTraceY > colY) then
				colX, colY = currentTraceX, currentTraceY
			end
		end
		
		if colY then --Ceiling collision
			self.y = colY+1
			self.speedY = math.max(self.speedY, 0)
			collisions.up = true
		end
	end
	
	if currentlyOnGround and not collisions.down then
		self.onGround = false
	end
end

function PhysObj:checkCollisions()
	if math.abs(self.speedX) > math.abs(self.speedY) then
		self:horCollisions()
		self:verCollisions()
	else
		self:verCollisions()
		self:horCollisions()
	end
end

function PhysObj:getX()
	return math.round(self.x)
end

function PhysObj:getY()
	return math.round(self.y)
end

function PhysObj:debugDraw(xOff, yOff)
	--love.graphics.setColor(255, 0, 0)
	--love.graphics.rectangle("line", self:getX()+.5, self:getY()+.5, self.width-1, self.height-1)
	
	love.graphics.setColor(0, 255, 0, 127)
	for j, w in ipairs(self.tracers.right) do
		w:debugDraw()
	end
	
	love.graphics.setColor(0, 0, 255, 127)
	for j, w in ipairs(self.tracers.left) do
		w:debugDraw()
	end
	
	love.graphics.setColor(255, 0, 255, 127)
	for j, w in ipairs(self.tracers.down) do
		w:debugDraw()
	end
	
	love.graphics.setColor(255, 255, 0, 127)
	for j, w in ipairs(self.tracers.up) do
		w:debugDraw()
	end
	
	love.graphics.setColor(255, 255, 255)
end

function PhysObj:leftCollision() end
function PhysObj:rightCollision() end
function PhysObj:bottomCollision() end
function PhysObj:topCollision() end

return PhysObj