local Vector = require "lib.Vector"
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
	self.onGround = true

	self.isGroundFor = {}
	self.inPortals = {}

	-- register yourself with the world
	world:addObject(self)

	self:createTracers()
end

function PhysObj:createTracers()
	-- More tracers than a quickplay match in Overwatch
	self.tracers = {}
	self.tracers.left = {}
	self.tracers.right = {}
	self.tracers.up = {}
	self.tracers.down = {}

	local step = self.world.tileSize

	-- Create left tracers
	local xOff = math.floor(self.width/2)-1
	local distance = math.floor(self.width/2)

	for yOff = self.height - Physics3.TRACER_BOTTOM_DIST - 1, Physics3.TRACER_SIDE_TOP_DIST+1, -step do
		table.insert(self.tracers.left, Physics3.Tracer:new(self, xOff, yOff, Vector(-distance, 0)))
	end

	-- Also include almost top
	table.insert(self.tracers.left, Physics3.Tracer:new(self, xOff, Physics3.TRACER_SIDE_TOP_DIST, Vector(-distance, 0)))


	-- Create right tracers
	xOff = math.floor(self.width/2)
	distance = math.floor(self.width/2)

	for yOff = self.height - Physics3.TRACER_BOTTOM_DIST - 1, Physics3.TRACER_SIDE_TOP_DIST+1, -step do
		table.insert(self.tracers.right, Physics3.Tracer:new(self, xOff, yOff, Vector(distance, 0)))
	end

	-- Also include almost top
	table.insert(self.tracers.right, Physics3.Tracer:new(self, xOff, Physics3.TRACER_SIDE_TOP_DIST, Vector(distance, 0)))


	-- Create bottom tracers
	local yOff = self.height/2
	distance = self.height/2+Physics3.TRACER_BOTTOM_EXTEND

	--from left side
	for xOff = 0+Physics3.TRACER_BOTTOM_SIDE_SPACING, math.floor(self.width/2)-1, Physics3.TRACER_BOTTOM_SPACING do
		table.insert(self.tracers.down, Physics3.Tracer:new(self, xOff, yOff, Vector(0, distance)))
	end

	--from right side
	for xOff = self.width-1-Physics3.TRACER_BOTTOM_SIDE_SPACING, math.floor(self.width/2), -Physics3.TRACER_BOTTOM_SPACING do
		table.insert(self.tracers.down, Physics3.Tracer:new(self, xOff, yOff, Vector(0, distance)))
	end


	-- Create top tracers
	yOff = self.height/2-1
	distance = self.height/2

	--from left side
	for xOff = 0+Physics3.TRACER_TOP_SPACING, math.floor(self.width/2)-1, step do
		table.insert(self.tracers.up, Physics3.Tracer:new(self, xOff, yOff, Vector(0, -distance)))
	end

	--from right side
	for xOff = self.width-1-Physics3.TRACER_TOP_SPACING, math.floor(self.width/2), -step do
		table.insert(self.tracers.up, Physics3.Tracer:new(self, xOff, yOff, Vector(0, -distance)))
	end
end

function PhysObj:changeSize(width, height)
	local diffX = self.width-width
	local diffY = self.height-height

	self.x = self.x + diffX/2
	self.y = self.y + diffY

	self.width = width
	self.height = height

	self:createTracers()
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
	local colX, colY, colObj

	for _, tracer in ipairs(self.tracers.left) do
		local traceX, traceY, traceObj = tracer:trace()

		if traceX and (not colX or traceX < colX) then
			colX, colY, colObj = traceX, traceY, traceObj
		end
	end

	return colX, colY, colObj
end

function PhysObj:rightColCheck()
	local colX, colY, colObj

	for _, tracer in ipairs(self.tracers.right) do
		local traceX, traceY, traceObj = tracer:trace()

		if traceX and (not colX or traceX > colX) then
			colX, colY, colObj = traceX, traceY, traceObj
		end
	end

	return colX, colY, colObj
end

function PhysObj:topColCheck()
	local colX, colY, colObj

	for _, tracer in ipairs(self.tracers.up) do
		local traceX, traceY, traceObj = tracer:trace()

		if traceX and (not colX or traceY < colY) then
			colX, colY, colObj = traceX, traceY, traceObj
		end
	end

	return colX, colY, colObj
end

function PhysObj:bottomColCheck()
	local colX, colY, colObj

	for _, tracer in ipairs(self.tracers.down) do
		local traceX, traceY, traceObj = tracer:trace()

		if traceX and (not colX or traceY < colY) then
			colX, colY, colObj = traceX, traceY, traceObj
		end
	end

	return colX, colY, colObj
end

function PhysObj:leftColResolve(obj, x, y)
	if not self:leftCollision(obj) then
		if x then
			if obj.class:isSubclassOf(PhysObj) then
				self.x = obj.x+obj.width
			else
				self.x = x+1
			end
		end

		self.speed[1] = math.max(self.speed[1], 0)
	end
end

function PhysObj:rightColResolve(obj, x, y)
	if not self:rightCollision(obj) then
		if x then
			if obj.class:isSubclassOf(PhysObj) then
				self.x = obj.x-self.width
			else
				self.x = x-self.width
			end
		end

		self.speed[1] = math.min(self.speed[1], 0)
	end
end

function PhysObj:topColResolve(obj, x, y)
	if not self:topCollision(obj) then
		if y then
			self.y = y+1
		end

		self.speed[2] = math.max(self.speed[2], 0)
	end
end

function PhysObj:bottomColResolve(obj, x, y)
	if not self:bottomCollision(obj) then
		if not self.onGround then
			self.onGround = true
		end

		if y then
			self.y = y-self.height
		end

		self.speed[2] = math.min(self.speed[2], 0)

		return true
	end

	return false
end

function PhysObj:checkCollisions()
	return	self:leftColCheck() or
			self:rightColCheck() or
			self:bottomColCheck() or
			self:topColCheck()
end

function PhysObj:resolveCollisions()
	if VAR("debug").tracerDebug then
		for _, group in pairs(self.tracers) do
			for _, tracer in ipairs(group) do
				tracer.tracedLength = 0
			end
		end
	end

	-- update self.inPortals
	clearTable(self.inPortals)

	for _, portal in ipairs(self.world.portals) do
		if objectWithinPortalRange(portal, self.x+self.width/2, self.y+self.height/2) then
			self.inPortals[portal] = true
		end
	end

	local x, y, obj

	if self.speed[1] <= 0 then
		x, y, obj = self:leftColCheck()
	end

	if x then -- resolve the left collision
		self:leftColResolve(obj, x, y)
		obj:rightColResolve(self)
	elseif self.speed[1] >= 0 then -- see if we got a right collision
		x, y, obj = self:rightColCheck()

		if x then -- resolve the right collision
			self:rightColResolve(obj, x, y)
			obj:leftColResolve(self)
		end
	end

	x = nil

	if self.speed[2] >= 0 then
		x, y, obj = self:bottomColCheck()
	end

	if x then
		if self.onGround or y <= self.y + self.height then
			if self:bottomColResolve(obj, x, y) then
				self.standingOn = obj

				if obj.class:isSubclassOf(PhysObj) then
					obj:getStoodOn(self)
				end
			end
			obj:topColResolve(self)

			if type(obj) == "table" and obj:isInstanceOf(Physics3.Cell) then -- update the object's surfaceAngle
				self.surfaceAngle = obj.tile.angle -- todo: May be wrong if colliding pixel is right underneath a slope's end!
			else
				self.surfaceAngle = 0
			end
		end
	else
		if self.onGround and self.speed[2] > 0 then -- start falling maybe
			self:startFall()
			self.onGround = false
		end

		x, y, obj = self:topColCheck()

		if x then -- resolve the right collision
			self:topColResolve(obj, x, y)

			obj:bottomColResolve(self)
		end
	end
end

function PhysObj:preMovement()
	self.standingOn = nil
	iClearTable(self.isGroundFor)
end

function PhysObj:postMovement()
	if self.standingOn and self.standingOn.class:isSubclassOf(PhysObj) then
		local mx, my = recursivelyGetFrameMovement(self.standingOn)

		self.x = self.x + mx
		self.y = self.y + my
	end
end

function PhysObj:checkCollision(x, y)
	if pointInRectangle(x, y, math.round(self.x), math.round(self.y), self.width, self.height) then
		return true
	end
end

function PhysObj:portalled()
	-- throw off anyone riding us
	for _, obj in ipairs(self.isGroundFor) do
		obj.standingOn = nil
	end

	iClearTable(self.isGroundFor)
end

function recursivelyGetFrameMovement(obj, x, y) -- god I hate recursion
    if not x then
        x = 0
        y = 0
    end

    x = x + obj.frameMovementX
    y = y + obj.frameMovementY

    if obj.standingOn and obj.standingOn.frameMovementX then
        local mx, my = recursivelyGetFrameMovement(obj.standingOn)

        x = x + mx
        y = y + my
    end

    return x, y
end

function PhysObj:getStoodOn(obj)
	table.insert(self.isGroundFor, obj)
end

function PhysObj:debugDraw(xOff, yOff)
	if not VAR("debug").tracerDebug then
		love.graphics.setColor(1, 0, 0)
		love.graphics.rectangle("line", self.x+.5, self.y+.5, self.width-1, self.height-1)
	end

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

function PhysObj:standingOnDebugDraw()
	love.graphics.print(tostring(self.standingOn), self.x+self.width, self.y)
end

function PhysObj:leftCollision() end
function PhysObj:rightCollision() end
function PhysObj:bottomCollision() end
function PhysObj:topCollision() end
function PhysObj:startFall() end

return PhysObj